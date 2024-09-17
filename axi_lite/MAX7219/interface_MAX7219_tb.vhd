library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; 

entity interface_MAX7219_tb is
end entity interface_MAX7219_tb;

architecture rtl of interface_MAX7219_tb is
    
    constant period_time : time      := 10000 ps;
    signal   finished    : std_logic := '0';
    
    component interface_MAX7219 is
        generic(
            CLK_FREQ : natural := 100000000
        );
        port(
            CLK   : in     std_logic;
            NRST  : in     std_logic;
            DATA  : in     std_logic_vector(15 downto 0);
            START : in     std_logic;
            DONE  : out     std_logic;
            SDO   : out     std_logic;
            SCL   : out     std_logic
        );
    end component;

    signal CLK   : std_logic := '0';
    signal NRST  : std_logic := '0';
    signal DATA  : std_logic_vector(15 downto 0) := (others => '0');
    signal START : std_logic := '0';
    signal DONE  : std_logic;
    signal SDO   : std_logic;
    signal SCL   : std_logic;
    
begin

    sim_time_proc: process
    begin
        -- Initialize inputs
        NRST <= '0';
        START <= '0';
        DATA <= (others => '0');
        wait for 100 ns;
        wait until rising_edge(CLK);

        NRST <= '1';
        wait for 100 ns;
        wait until rising_edge(CLK);

        DATA <= x"1234"; 
        START <= '1';
        wait for 1 ns;
        wait until rising_edge(CLK);
        START <= '0';
        wait until DONE = '1';

        wait for 100 us;
        wait until rising_edge(CLK);

        DATA <= x"5A5A"; 
        START <= '1';
        wait for 1 ns;
        wait until rising_edge(CLK);
        START <= '0';
        wait until DONE = '1';

        DATA <= x"BEEF"; 
        START <= '1';
        wait for 1 ns;
        wait until rising_edge(CLK);
        START <= '0';
        wait until DONE = '1';

        wait for 100 us;
        wait for 1 ns;
        wait until rising_edge(CLK);

        DATA <= x"DEAD"; 
        START <= '1';
        wait for 1 ns;
        wait until rising_edge(CLK);
        START <= '0';
        wait until DONE = '1';


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
    
    uut: interface_MAX7219
        port map (
            CLK   => CLK,
            NRST  => NRST,
            DATA  => DATA,
            START => START,
            DONE  => DONE,
            SDO   => SDO,
            SCL   => SCL
        );

end architecture rtl; 