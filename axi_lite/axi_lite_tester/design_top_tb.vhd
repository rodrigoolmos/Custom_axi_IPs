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

    type RAM_TYPE is array (0 to 3) of std_logic_vector(31 downto 0);
        signal ram_read : RAM_TYPE;

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
            
            clk : in STD_LOGIC;
            nrst : in STD_LOGIC

        );
    end component design_top;

    procedure send_data(
        constant data                   : std_logic_vector ( 31 downto 0 );
        constant addr                   : std_logic_vector ( 31 downto 0 );
        signal m00_axi_init_axi_txn0    : out std_logic;
        signal m00_axi_txn_ready0       : in  std_logic;
        signal test_wdata0              : out std_logic_vector ( 31 downto 0 );
        signal test_awaddr0             : out std_logic_vector ( 31 downto 0 )
    ) is
    begin

        wait until rising_edge(clk);
        m00_axi_init_axi_txn0 <= '1';
        test_wdata0 <= data;
        test_awaddr0 <= addr;
        wait until rising_edge(clk);
        m00_axi_init_axi_txn0 <= '0';
        wait until m00_axi_txn_ready0 = '1';
        wait until rising_edge(clk);

    end procedure;

    procedure recive_data(
        signal data                     : out std_logic_vector ( 31 downto 0 );
        constant addr                   : std_logic_vector ( 31 downto 0 );
        signal m00_axi_init_axi_rxn0    : out std_logic;
        signal m00_axi_rxn_ready0       : in  std_logic;
        signal test_araddr0             : out std_logic_vector ( 31 downto 0 );
        signal test_rdata0               : in std_logic_vector(31 downto 0)
    ) is
    begin

        wait until rising_edge(clk);
        m00_axi_init_axi_rxn0 <= '1';
        test_araddr0 <= addr;
        wait until rising_edge(clk);
        m00_axi_init_axi_rxn0 <= '0';
        wait until m00_axi_rxn_ready0 = '1';
        data <= test_rdata;
        wait until rising_edge(clk);

    end procedure;
    
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

        send_data(x"12345678", x"12345670", m00_axi_init_axi_txn, m00_axi_txn_ready, test_wdata, test_awaddr);
        send_data(x"11223344", x"12345674", m00_axi_init_axi_txn, m00_axi_txn_ready, test_wdata, test_awaddr);
        send_data(x"BADC0FFE", x"12345678", m00_axi_init_axi_txn, m00_axi_txn_ready, test_wdata, test_awaddr);
        send_data(x"DEADFEED", x"1234567C", m00_axi_init_axi_txn, m00_axi_txn_ready, test_wdata, test_awaddr);

        
        recive_data( ram_read(0), x"12345670", m00_axi_init_axi_rxn, m00_axi_rxn_ready, test_araddr, test_rdata);
        recive_data( ram_read(1), x"12345674", m00_axi_init_axi_rxn, m00_axi_rxn_ready, test_araddr, test_rdata);
        recive_data( ram_read(2), x"12345678", m00_axi_init_axi_rxn, m00_axi_rxn_ready, test_araddr, test_rdata);
        recive_data( ram_read(3), x"1234567C", m00_axi_init_axi_rxn, m00_axi_rxn_ready, test_araddr, test_rdata);

        wait for 10 us;
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

        
        clk => clk,
        nrst => nrst


    );

end architecture rtl;