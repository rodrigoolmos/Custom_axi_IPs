library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fifo_tb is
end entity fifo_tb;

architecture rtl of fifo_tb is
    
    constant period_time : time      := 83333 ps;
    constant data_width : natural := 8;
    signal   finished    : std_logic := '0';
    
    signal CLK :        std_logic;
    signal nrst :       std_logic;
    signal ena_write :  std_logic;
    signal ena_read :   std_logic;
    signal empty :      std_logic;
    signal full :       std_logic;
    signal data_write : std_logic_vector(data_width -1 downto 0);
    signal data_read :  std_logic_vector(data_width -1 downto 0);
    
    component fifo is
        generic(
            data_width : natural := 8;
            addr_deep  :  natural := 16
        );
        port(
            CLK :        in     std_logic;
            nrst :       in     std_logic;
            ena_write :  in     std_logic;
            ena_read :   in     std_logic;
            empty :      out    std_logic;
            full :       out    std_logic;
            data_write : in     std_logic_vector(data_width -1 downto 0);
            data_read :  out    std_logic_vector(data_width -1 downto 0)
        );
    end component fifo;
    
begin

    sim_time_proc: process
    begin
        nrst <= '0';
        ena_write <= '0';
        ena_read <= '0';
        wait until rising_edge(CLK);
        nrst <= '1';
        wait until rising_edge(CLK);
        ena_write <= '1';
        data_write <= x"00";
        wait until rising_edge(CLK);
        data_write <= x"01";
        wait until rising_edge(CLK);
        data_write <= x"02";
        wait until rising_edge(CLK);
        data_write <= x"03";
        wait until rising_edge(CLK);
        data_write <= x"04";
        wait until rising_edge(CLK);
        data_write <= x"05";
        wait until rising_edge(CLK);
        data_write <= x"06";
        wait until rising_edge(CLK);
        data_write <= x"07";
        wait until rising_edge(CLK);
        data_write <= x"08";
        wait until rising_edge(CLK);
        data_write <= x"09";
        wait until rising_edge(CLK);
        data_write <= x"0A";
        wait until rising_edge(CLK);
        data_write <= x"0B";
        wait until rising_edge(CLK);
        data_write <= x"0C";
        wait until rising_edge(CLK);
        data_write <= x"0D";
        wait until rising_edge(CLK);
        data_write <= x"0E";
        wait until rising_edge(CLK);
        data_write <= x"0F";
        wait until rising_edge(CLK);
        data_write <= x"10";
        wait until rising_edge(CLK);
        data_write <= x"20";
        wait until rising_edge(CLK);
        data_write <= x"30";
        wait until rising_edge(CLK);
        ena_read <= '1';
        ena_write <= '0';
        wait until rising_edge(CLK);
        wait until rising_edge(CLK);
        wait until rising_edge(CLK);
        wait until rising_edge(CLK);
        wait until rising_edge(CLK);
        wait until rising_edge(CLK);
        wait until rising_edge(CLK);
        wait until rising_edge(CLK);
        wait until rising_edge(CLK);
        wait until rising_edge(CLK);
        wait until rising_edge(CLK);
        wait until rising_edge(CLK);
        wait until rising_edge(CLK);
        wait until rising_edge(CLK);
        wait until rising_edge(CLK);
        wait until rising_edge(CLK);
        wait until rising_edge(CLK);
        
        ena_write <= '1';
        ena_read <= '0';
        data_write <= x"10";
        wait until rising_edge(CLK);
        data_write <= x"11";
        wait until rising_edge(CLK);
        data_write <= x"12";
        wait until rising_edge(CLK);
        data_write <= x"13";
        wait until rising_edge(CLK);
        data_write <= x"14";
        wait until rising_edge(CLK);
        data_write <= x"15";
        wait until rising_edge(CLK);
        data_write <= x"16";
        wait until rising_edge(CLK);
        data_write <= x"17";
        wait until rising_edge(CLK);
        data_write <= x"18";
        wait until rising_edge(CLK);
        data_write <= x"19";
        wait until rising_edge(CLK);
        data_write <= x"1A";
        wait until rising_edge(CLK);
        data_write <= x"1B";
        wait until rising_edge(CLK);
        data_write <= x"1C";
        wait until rising_edge(CLK);
        data_write <= x"1D";
        wait until rising_edge(CLK);
        data_write <= x"1E";
        wait until rising_edge(CLK);
        data_write <= x"1F";
        wait until rising_edge(CLK);
        data_write <= x"20";
        wait until rising_edge(CLK);
        data_write <= x"30";
        wait until rising_edge(CLK);
        data_write <= x"40";
        wait until rising_edge(CLK);
        
        ena_read <= '1';
        ena_write <= '1';
        
        data_write <= x"00";
        wait until rising_edge(CLK);
        data_write <= x"01";
        wait until rising_edge(CLK);
        data_write <= x"02";
        wait until rising_edge(CLK);
        data_write <= x"03";
        wait until rising_edge(CLK);
        data_write <= x"04";
        wait until rising_edge(CLK);
        data_write <= x"05";
        wait until rising_edge(CLK);
        data_write <= x"06";
        wait until rising_edge(CLK);
        data_write <= x"07";
        wait until rising_edge(CLK);
        data_write <= x"08";
        wait until rising_edge(CLK);
        data_write <= x"09";
        wait until rising_edge(CLK);
        data_write <= x"0A";
        wait until rising_edge(CLK);
        data_write <= x"0B";
        wait until rising_edge(CLK);
        data_write <= x"0C";
        wait until rising_edge(CLK);
        data_write <= x"0D";
        wait until rising_edge(CLK);
        data_write <= x"0E";
        wait until rising_edge(CLK);
        data_write <= x"0F";
        wait until rising_edge(CLK);
        data_write <= x"10";
        wait until rising_edge(CLK);
        data_write <= x"20";
        wait until rising_edge(CLK);
        data_write <= x"30";
        wait until rising_edge(CLK);
        
        
        ena_write <= '1';
        ena_read <= '0';
        data_write <= x"00";
        wait until rising_edge(CLK);
        data_write <= x"01";
        wait until rising_edge(CLK);
        data_write <= x"02";
        wait until rising_edge(CLK);
        data_write <= x"03";
        wait until rising_edge(CLK);
        data_write <= x"04";
        wait until rising_edge(CLK);
        data_write <= x"05";
        wait until rising_edge(CLK);
        data_write <= x"06";
        wait until rising_edge(CLK);
        data_write <= x"07";
        wait until rising_edge(CLK);
        data_write <= x"08";
        wait until rising_edge(CLK);
        data_write <= x"09";
        wait until rising_edge(CLK);
        data_write <= x"0A";
        wait until rising_edge(CLK);
        data_write <= x"0B";
        wait until rising_edge(CLK);
        data_write <= x"0C";
        wait until rising_edge(CLK);
        data_write <= x"0D";
        wait until rising_edge(CLK);
        data_write <= x"0E";
        wait until rising_edge(CLK);
        data_write <= x"0F";
        wait until rising_edge(CLK);
        data_write <= x"10";
        wait until rising_edge(CLK);
        data_write <= x"20";
        wait until rising_edge(CLK);
        data_write <= x"30";
        wait until rising_edge(CLK);
        
        finished <= '1';
        wait;
    end process sim_time_proc;

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
    
    u1: fifo
    port map
    (
        CLK        => CLK ,
        nrst       => nrst ,
        ena_write  => ena_write ,
        ena_read   => ena_read ,
        empty      => empty ,
        full       => full ,
        data_write => data_write ,
        data_read  => data_read
    );

end architecture rtl;