library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uart is
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
end entity uart;

architecture rtl of uart is
    signal counter_rx : integer range 0 to clk_tics_per_bit := 0;
    signal counter_tx: integer range 0 to clk_tics_per_bit := 0;
    signal n_bit_rx : integer range 0 to 7 := 0;
    signal n_bit_tx : integer range 0 to 7 := 0;
    signal byte_tx_reg : std_logic_vector(7 downto 0);
    signal new_bit_rx : std_logic;

    
    signal rx_byte : std_logic_vector(7 downto 0);
    type t_State is (idle, start_bit, reciving, stop_bit);
    signal State_rx : t_State;
    signal State_tx : t_State;

begin

    rx_proc: process(clk, nrst)
    begin
        if nrst = '0' then
            counter_rx <= 0;
            byte_ready <= '0';
            n_bit_rx <= 0;
            State_rx <= idle;
            new_bit_rx <= '0';
            rx_byte <= (others => '0');
        elsif rising_edge(clk) then
            case State_rx is
                when idle =>
                    byte_ready <= '0';

                    if uart_rx = '0' then
                        State_rx <= start_bit;
                    end if;

                when start_bit =>
                    if counter_rx < clk_tics_per_bit/2 - 2 then
                        counter_rx <= counter_rx + 1;
                    else
                        counter_rx <= 0;
                        State_rx <= reciving;
                    end if;

                when reciving =>
                    if counter_rx < clk_tics_per_bit then
                        counter_rx <= counter_rx + 1;
                        new_bit_rx <= '0';
                    else
                        new_bit_rx <= '1';
                        if n_bit_rx < 7 then
                            n_bit_rx <= n_bit_rx + 1;
                            rx_byte(n_bit_rx) <= uart_rx;
                        else
                            rx_byte(n_bit_rx) <= uart_rx;
                            n_bit_rx <= 0;
                            State_rx <= stop_bit;
                        end if;
                        counter_rx <= 0;
                    end if;

                when stop_bit =>
                    new_bit_rx <= '0';

                    if counter_rx < clk_tics_per_bit then
                        counter_rx <= counter_rx + 1;
                    else
                        byte_ready <= '1';
                        State_rx <= idle;
                        counter_rx <= 0;
                    end if;

                when others =>
                    State_rx <= idle;
                    
            end case;
        end if;
    end process rx_proc;
    
    
    tx_proc: process(clk, nrst)
    begin
        if nrst = '0' then
            counter_tx<= 0;
            done_tx <= '1';
            n_bit_tx <= 0;
            State_tx <= idle;
            uart_tx <= '1';
            byte_tx_reg <= (others => '0');
        elsif rising_edge(clk) then
            case State_tx is
                when idle =>
                    if start_tx = '1' then
                        done_tx <= '0';
                        State_tx <= start_bit;
                    end if;

                when start_bit =>
                    if counter_tx< clk_tics_per_bit then
                        counter_tx <= counter_tx + 1;
                        uart_tx <= '0';
                        if counter_tx = 0 then
                            byte_tx_reg <= byte_tx;
                        end if;
                    else
                        counter_tx <= 0;
                        State_tx <= reciving;
                    end if;

                when reciving =>
                    if counter_tx < clk_tics_per_bit then
                        counter_tx <= counter_tx + 1;
                        uart_tx <= byte_tx_reg(n_bit_tx);
                    else
                        counter_tx <= 0;
                        if n_bit_tx < 7 then
                            n_bit_tx <= n_bit_tx + 1;
                        else
                            n_bit_tx <= 0;
                            State_tx <= stop_bit;
                        end if;
                    end if;
                when stop_bit =>
                    if counter_tx< clk_tics_per_bit then
                        uart_tx <= '1';
                        counter_tx <= counter_tx + 1;
                    else
                        counter_tx <= 0;
                        done_tx <= '1';
                        State_tx <= idle;
                    end if;
                when others =>
                    State_tx <= idle;

            end case;
        end if;
    end process tx_proc;
    
    byte_rx <= rx_byte;

end architecture rtl;