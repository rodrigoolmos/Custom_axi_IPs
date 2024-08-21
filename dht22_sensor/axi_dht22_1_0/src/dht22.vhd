library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity dht22 is
    generic(
        clk_frec : natural := 100000000
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
        data_t : out    std_logic;
        data_i : out    std_logic;
        data_o : in    std_logic;
        -- temperature
        int_t : out     std_logic_vector(7 downto 0);
        float_t : out   std_logic_vector(7 downto 0);
        -- humidity
        int_h : out     std_logic_vector(7 downto 0);
        float_h : out   std_logic_vector(7 downto 0);
        -- error signal
        crc : out       std_logic_vector(7 downto 0)

    );
end entity dht22;

architecture rtl of dht22 is

    attribute MARK_DEBUG : string;

    type st_dht22 is (idle, start_sig, wait_response, pull_low, pull_high, reciving);
    signal dht22_s : st_dht22;
    
    signal counter : natural range 0 to clk_frec;
    signal n_bit :   natural range 0 to 39;
    signal rx_data : std_logic_vector(39 downto 0);
    signal data_reg : std_logic_vector(2 downto 0);
    signal data_s : std_logic;

    attribute MARK_DEBUG of dht22_s : signal is "TRUE";
    attribute MARK_DEBUG of n_bit : signal is "TRUE";
    attribute MARK_DEBUG of rx_data : signal is "TRUE";
    attribute MARK_DEBUG of data_reg : signal is "TRUE";
    
    attribute MARK_DEBUG of start : signal is "TRUE";
    attribute MARK_DEBUG of reset : signal is "TRUE";
    attribute MARK_DEBUG of done : signal is "TRUE";
    attribute MARK_DEBUG of error : signal is "TRUE";
    
begin
    
    process(clk, nrst)
    begin
        if nrst = '0' then
            data_reg <= "000";
        elsif rising_edge(clk) then
            data_reg <= data_reg(1 downto 0) & data_s;
        end if;
    end process;

    process(clk, nrst)
    begin
        if nrst = '0' then
            dht22_s <= idle;
            counter <= 0;
            rx_data <= x"0123456789";
            n_bit <= 39;
            done <= '0';
        elsif rising_edge(clk) then
            if reset = '1' then
                dht22_s <= idle;
                counter <= 0;
                rx_data <= x"0123456789";
                n_bit <= 39;
                done <= '0';
            else
                case dht22_s is
                    when idle =>
                        if start = '1' then
                            dht22_s <= start_sig;
                            rx_data <= x"0123456789";
                            done <= '0';
                        end if;
                    when start_sig =>
                        if counter < clk_frec/50 then
                            counter <= counter + 1;
                        else
                            counter <= 0;
                            dht22_s <= wait_response;
                        end if;
                    when wait_response =>
                        if data_reg(2) = '0' then
                            dht22_s <= pull_low;
                        end if;
                    when pull_low =>
                        if data_reg(2) = '1' then --------------------------- simulation Z implementation 1
                            dht22_s <= pull_high;
                        end if;
                    when pull_high =>
                        if data_reg(2) = '0' then
                            dht22_s <= reciving;
                        end if;
                    when reciving =>
                        if data_reg(2) = '1' and data_reg(1) = '0' then ----- simulation Z implementation 1
                            if n_bit > 0 then
                                n_bit <= n_bit - 1;
                            else
                                dht22_s <= idle;
                                done <= '1';
                                n_bit <= 39;
                            end if;
                            if counter < clk_frec/20000 then
                                rx_data(n_bit) <= '0';
                            else
                                rx_data(n_bit) <= '1';
                            end if;
                        end if;
                        if data_reg(1) = '1' then --------------------------- simulation Z implementation 1
                            counter <= counter + 1;
                        else
                            counter <= 0;
                        end if;
                    when others =>
                        dht22_s <= idle;
                end case;
            end if;
        end if;
    end process;
    
    data_s <= data_o;
    
    data_i <= '0';
    data_t <= '0' when (dht22_s = start_sig) and (counter < clk_frec/1000 - 3) else 'Z';
    
    int_h <= rx_data(39 downto 32);
    float_h <= rx_data(31 downto 24);
    int_t <= rx_data(23 downto 16);
    float_t <= rx_data(15 downto 8);
    crc <= rx_data(7 downto 0);

    error <= '0' when rx_data(7 downto 0) = std_logic_vector(
        unsigned(rx_data(39 downto 32)) +
        unsigned(rx_data(15 downto 8)) +
        unsigned(rx_data(23 downto 16)) +
        unsigned(rx_data(31 downto 24))) else '1';
    
end architecture rtl;