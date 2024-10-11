library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity RGB_matrix_tb is
end entity RGB_matrix_tb;

architecture rtl of RGB_matrix_tb is
    
    constant period_time : time      := 10000 ps;
    signal   finished    : std_logic := '0';
    
    component RGB_matrix
    port(
        CLK     : in    std_logic;
        NRST    : in    std_logic;
        DEBUG   : in    std_logic;
        data    : in    std_logic_vector(7 downto 0);
        n_row   : out   std_logic_vector(7 downto 0);
        n_col   : out   std_logic_vector(7 downto 0);
        RGB0    : out   std_logic_vector(2 downto 0);
        RGB1    : out   std_logic_vector(2 downto 0);
        ADDR    : out   std_logic_vector(4 downto 0);
        LAT     : out   std_logic;
        CLOCK_O : out   std_logic;
        OE      : out   std_logic
    );
end component;

    -- Signals to connect to UUT
signal CLK     : std_logic := '0';
signal NRST    : std_logic := '0';
signal DEBUG   : std_logic;
signal data    :  std_logic_vector(7 downto 0);
signal n_row   :  std_logic_vector(7 downto 0);
signal n_col   :  std_logic_vector(7 downto 0);
signal RGB0    : std_logic_vector(2 downto 0);
signal RGB1    : std_logic_vector(2 downto 0);
signal ADDR    : std_logic_vector(4 downto 0);
signal LAT     : std_logic;
signal CLOCK_O : std_logic;
signal OE      : std_logic;

begin

    sim_time_proc: process
    begin
        NRST <= '0';
        DEBUG <= '1';
        wait for 10 us;
        wait until rising_edge(CLK);
        NRST <= '1';
        wait until rising_edge(CLK);


        
        wait for 10 ms;
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
    
    uut: RGB_matrix
    port map (
        CLK     => CLK,
        NRST    => NRST,
        DEBUG   => DEBUG,
        data    => data,
        n_row   => n_row,
        n_col   => n_col,
        RGB0    => RGB0,
        RGB1    => RGB1,
        ADDR    => ADDR,
        LAT     => LAT,
        CLOCK_O => CLOCK_O,
        OE      => OE
    );

end architecture rtl;