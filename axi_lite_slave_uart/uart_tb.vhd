library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uart_tb is
end entity uart_tb;

architecture rtl of uart_tb is
    
    constant period_time : time := 83333 ps; -- 12MHz
    constant baud_rate : natural := 9600;
    constant bite_time : time := 1000000 / baud_rate * 1 us;
    constant clk_tics_per_bit : natural := bite_time/period_time;
    signal   finished  : std_logic := '0';
    
    signal clk :            std_logic;
    signal nrst :           std_logic;
    signal uart_rx :        std_logic;
    signal uart_tx :        std_logic;
    signal byte_ready :     std_logic;
    signal start_tx :       std_logic;
    signal done_tx :        std_logic;
    signal byte_tx_tmp :    std_logic_vector(7 downto 0);
    signal byte_rx :        std_logic_vector(7 downto 0);
    signal byte_tx :        std_logic_vector(7 downto 0);
    signal rx_byte_tb :     std_logic_vector(7 downto 0);

    
    component uart is
        generic(
            clk_tics_per_bit : integer := 6);
        port(
            clk : in            std_logic;
            nrst : in           std_logic;
            uart_rx : in        std_logic;
            uart_tx : out       std_logic;
            byte_ready : out    std_logic;
            start_tx : in       std_logic;
            done_tx : out       std_logic;
            byte_rx : out       std_logic_vector(7 downto 0);
            byte_tx : in        std_logic_vector(7 downto 0)
        );
    end component uart;

    procedure simulate_tx(
        constant data         : in std_logic_vector(7 downto 0);
        signal rx             : out std_logic
    ) is
    begin
        -- start bituart_rx
        rx <= '0';
        -- data
        wait for bite_time ;
        for i in 0 to 7 loop
            rx <= data(i);
            wait for bite_time ;
        end loop;
        -- stop bit
        rx <= '1';
        wait for bite_time ;
    end procedure;
    
    procedure generate_tx(
        constant tx_data         : in std_logic_vector(7 downto 0);
        signal tx_buffer         : out std_logic_vector(7 downto 0);
        signal done              : in std_logic;
        signal clk_sig           : in std_logic;
        signal start             : out std_logic

    ) is
    begin
        start <= '1';
        tx_buffer <= tx_data;
        wait until rising_edge(clk_sig);
        wait until done = '1' and rising_edge(clk_sig);
        start <= '0';
    end procedure;
    
begin

    check_rx: process
    begin
        if byte_ready = '1' then
            assert not byte_tx_tmp /= byte_rx report "ERROR RX UART" severity ERROR;
        end if;
        wait;
    end process check_rx;
    
    
    check_tx: process
    begin
        if done_tx = '1' then
            assert not rx_byte_tb /= byte_tx report "ERROR RX UART" severity ERROR;
        end if;
        wait;
    end process check_tx;

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

    test_uart: process
    begin
        nrst <= '0';
        uart_rx <= '1';
        wait for 1 ns;
        nrst <= '1';
        wait for 10 ns;
        -- test rx
        for i in 0 to 255 loop
            byte_tx_tmp <= std_logic_vector(to_unsigned(i, byte_tx_tmp'length));
            wait for 1 ps;
            simulate_tx(byte_tx_tmp, uart_rx);
        end loop;

        -- test tx
        for i in 0 to 255 loop
            byte_tx_tmp <= std_logic_vector(to_unsigned(i, byte_tx_tmp'length));
            wait until rising_edge(clk);
            generate_tx(byte_tx_tmp, byte_tx, done_tx, clk, start_tx);

        end loop;
        
        finished <= '1';
        wait;
    end process test_uart;


    rx_proc: process
    begin
        while finished /= '1' loop

            wait until uart_tx = '0';
            wait for 3*bite_time/2;
            for i in 0 to 7 loop
                rx_byte_tb(i) <= uart_tx;
                wait for bite_time ;
            end loop;
            wait for bite_time/2 ;
        end loop;

        wait;
    end process rx_proc;

    u1: uart
    generic map(
        clk_tics_per_bit => clk_tics_per_bit)
    port map
    (
        clk => clk,
        nrst => nrst,
        uart_rx => uart_rx,
        uart_tx => uart_tx,
        byte_ready => byte_ready,
        start_tx => start_tx,
        done_tx => done_tx,
        byte_rx => byte_rx,
        byte_tx => byte_tx
    );

end architecture rtl;