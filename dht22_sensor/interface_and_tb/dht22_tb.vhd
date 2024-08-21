library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity dht22_tb is
end entity dht22_tb;

architecture rtl of dht22_tb is
    
    constant period_time : time      := 83333 ps;
    signal   finished    : std_logic := '0';
    
    signal clk :                std_logic;
    signal nrst :               std_logic;
    signal start :              std_logic;
    signal reset :              std_logic;
    signal done :               std_logic;
    signal error :              std_logic;
    signal data :               std_logic;
    signal temperature_h :      std_logic_vector(7 downto 0);
    signal temperature_l :      std_logic_vector(7 downto 0);
    signal humidity_h :         std_logic_vector(7 downto 0);
    signal humidity_l :         std_logic_vector(7 downto 0);
    signal crc :                std_logic_vector(7 downto 0);
    
    component dht22 is
        generic(
            clk_frec : natural := 12000000
        );
        port(
            clk : in        std_logic;
            nrst : in       std_logic;
            -- control signals
            start : in      std_logic;
            reset : in      std_logic;
            done : out      std_logic;
            error : out     std_logic;
            -- tristate
            data : inout    std_logic;
            -- temperature
            temperature_h : out     std_logic_vector(7 downto 0);
            temperature_l : out   std_logic_vector(7 downto 0);
            -- humidity
            humidity_h : out     std_logic_vector(7 downto 0);
            humidity_l : out   std_logic_vector(7 downto 0);
            -- error signal
            crc : out       std_logic_vector(7 downto 0)

        );
    end component dht22;
    
    procedure tx_data(
        constant data_2_send         : in std_logic_vector(39 downto 0);
        signal tx_signal             : out std_logic
    ) is
    begin

        for i in 0 to 39 loop
            tx_signal <= '0';
            wait for 50 us;
            if data_2_send(39 - i) = '1' then
                tx_signal <= '1';
                wait for 70 us;
            else
                tx_signal <= '1';
                wait for 27 us;
            end if;
        end loop;

    end procedure;
begin

    process
    begin
        nrst <= '0';
        start <= '0';
        reset <= '0';
        wait for 200 ns;
        nrst <= '1';
        wait for 200 us;
        
        wait until rising_edge(clk);
        start <= '1';
        wait until rising_edge(clk);
        start <= '0';
        wait for 20 ms;

        wait until rising_edge(clk);
        start <= '1';
        wait until rising_edge(clk);
        start <= '0';
        wait for 20 ms;
        
        wait until rising_edge(clk);
        start <= '1';
        wait until rising_edge(clk);
        start <= '0';
        wait for 20 ms;
        
        wait until rising_edge(clk);
        start <= '1';
        wait until rising_edge(clk);
        start <= '0';
        wait for 20 ms;
        wait until rising_edge(clk);
        reset <= '1';
        wait until rising_edge(clk);
        reset <= '0';
        
        wait until rising_edge(clk);
        start <= '1';
        wait until rising_edge(clk);
        start <= '0';
        wait for 20 ms;
        
        finished <= '1';
        wait;
    end process;
    
    
    sim_dht22: process
    begin
        data <= 'Z';

        wait until data = '0';
        wait until data = 'Z';
        wait for 30 us;
        data <= '0';
        wait for 80 us;
        data <= '1';
        wait for 80 us;
        tx_data(x"0123456789", data);
        data <= '0';
        wait for 50 us;
        data <= 'Z';
        
        wait until data = '0';
        wait until data = 'Z';
        wait for 30 us;
        data <= '0';
        wait for 80 us;
        data <= '1';
        wait for 80 us;
        tx_data(x"8DEADBEEF8", data);
        data <= '0';
        wait for 50 us;
        data <= 'Z';

        wait until data = '0';
        wait until data = 'Z';
        wait for 30 us;
        data <= '0';
        wait for 80 us;
        data <= '1';
        wait for 80 us;
        tx_data(x"D1B16B00B5", data);
        data <= '0';
        wait for 50 us;
        data <= 'Z';
        
        -- simulate bugg in the dht22
        wait until data = '0';
        wait until data = 'Z';
        wait for 30 us;
        data <= '0';
        wait for 80 us;
        data <= '1';
        wait for 80 us;
        data <= '0';
        wait until reset = '1';
        data <= 'Z';
        
        wait until data = '0';
        wait until data = 'Z';
        wait for 30 us;
        data <= '0';
        wait for 80 us;
        data <= '1';
        wait for 80 us;
        tx_data(x"20ABADCAFE", data);
        data <= '0';
        wait for 50 us;
        data <= 'Z';
        
        wait;
    end process sim_dht22;

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
    
    u1: dht22
    generic map (
        clk_frec    => 12000000
    )
    port map
    (
        clk => clk,
        nrst => nrst,
        
        start => start,
        reset => reset,
        done => done,
        error => error,
        data => data,
        
        temperature_h => temperature_h,
        temperature_l => temperature_l,
        
        humidity_h => humidity_h,
        humidity_l => humidity_l,

        crc => crc
    );

end architecture rtl;