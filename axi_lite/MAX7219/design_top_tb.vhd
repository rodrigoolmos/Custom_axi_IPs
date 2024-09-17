library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity design_top_tb is
end entity design_top_tb;

architecture rtl of design_top_tb is
    
    constant period_time : time      := 83333 ps;
    signal   finished    : std_logic := '0';
    
    signal clk :        std_logic;
    signal nrst :       std_logic;
    signal m00_axi_init_axi_txn : std_logic;
    signal m00_axi_init_axi_rxn : std_logic;

    signal m00_axi_txn_ready : std_logic;
    signal m00_axi_rxn_ready : std_logic;
    
    signal test_wdata : std_logic_vector(31 downto 0);
    signal test_awaddr : std_logic_vector(31 downto 0);
    signal test_araddr : std_logic_vector(31 downto 0);
    signal test_rdata : std_logic_vector(31 downto 0);

    signal SDO : std_logic;
    signal SCL : std_logic;
    signal CS : std_logic;
    
    component design_top is
        port (
        ------------- debug from tb ----------
            test_wdata  : in std_logic_vector(31 downto 0);
            test_awaddr : in std_logic_vector(31 downto 0);
            test_araddr : in std_logic_vector(31 downto 0);
            test_rdata  : out std_logic_vector(31 downto 0);
            m00_axi_init_axi_txn : in STD_LOGIC;
            m00_axi_init_axi_rxn : in STD_LOGIC;
            m00_axi_txn_ready : out STD_LOGIC;
            m00_axi_rxn_ready : out STD_LOGIC;
        -------------------------------------
            
            SDO   : out     std_logic;
            SCL   : out     std_logic;
            CS   : out     std_logic;


            clk : in STD_LOGIC;
            nrst : in STD_LOGIC

        );
    end component design_top;
    
begin


    clk_proc: process
    begin
        while finished /= '1' loop
            CLK <= '0';
            wait for period_time/2;
            CLK <= '1';
            wait for period_time/2;
        end loop;
        wait;
    end process clk_proc;
    
    process
    begin
        nrst <= '0';
        m00_axi_init_axi_txn <= '0';
        m00_axi_init_axi_rxn <= '0';

        wait until rising_edge(clk);
        nrst <= '1';
        wait until rising_edge(clk);

        loop
            m00_axi_init_axi_rxn <= '1';
            test_araddr <= x"12345674";
            wait until rising_edge(clk);
            m00_axi_init_axi_rxn <= '0';
            wait until m00_axi_rxn_ready = '1';
            exit when test_rdata(0) = '1';
        end loop;
        
        m00_axi_init_axi_txn <= '1';
        test_wdata <= x"12345678";
        test_awaddr <= x"12345670";
        wait until rising_edge(clk);
        m00_axi_init_axi_txn <= '0';
        wait until m00_axi_txn_ready = '1';


        loop
            m00_axi_init_axi_rxn <= '1';
            test_araddr <= x"12345674";
            wait until rising_edge(clk);
            m00_axi_init_axi_rxn <= '0';
            wait until m00_axi_rxn_ready = '1';
            exit when test_rdata(0) = '1';
        end loop;
        
        m00_axi_init_axi_txn <= '1';
        test_wdata <= x"55555555";
        test_awaddr <= x"12345670";
        wait until rising_edge(clk);
        m00_axi_init_axi_txn <= '0';
        wait until m00_axi_txn_ready = '1';

        loop
            m00_axi_init_axi_rxn <= '1';
            test_araddr <= x"12345674";
            wait until rising_edge(clk);
            m00_axi_init_axi_rxn <= '0';
            wait until m00_axi_rxn_ready = '1';
            exit when test_rdata(0) = '1';
        end loop;
        
        m00_axi_init_axi_txn <= '1';
        test_wdata <= x"BADCAFFE";
        test_awaddr <= x"12345670";
        wait until rising_edge(clk);
        m00_axi_init_axi_txn <= '0';
        wait until m00_axi_txn_ready = '1';
        
        loop
            m00_axi_init_axi_rxn <= '1';
            test_araddr <= x"12345674";
            wait until rising_edge(clk);
            m00_axi_init_axi_rxn <= '0';
            wait until m00_axi_rxn_ready = '1';
            exit when test_rdata(0) = '1';
        end loop;
        
        wait for 10 ms;
        finished <= '1';
        wait;
    end process;


    u1: design_top
    port map
    (
        ------------- debug from tb ----------
        test_wdata  => test_wdata,
        test_awaddr => test_awaddr,
        test_araddr => test_araddr,
        test_rdata  => test_rdata,
        m00_axi_init_axi_txn => m00_axi_init_axi_txn,
        m00_axi_init_axi_rxn => m00_axi_init_axi_rxn,
        m00_axi_txn_ready => m00_axi_txn_ready,
        m00_axi_rxn_ready => m00_axi_rxn_ready,
        --------------------------------------

        SDO => SDO,
        SCL => SCL,
        CS =>  CS,
        
        clk => clk,
        nrst => nrst

    );

end architecture rtl;