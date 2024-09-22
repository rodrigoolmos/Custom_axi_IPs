library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity interface_MAX7219 is
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
end entity interface_MAX7219;

architecture rtl of interface_MAX7219 is
    constant MAX_SCL_FREQ : natural := 1000000;
    constant MAX_COUNT : natural := CLK_FREQ/MAX_SCL_FREQ;
    signal counter : natural range 0 to MAX_COUNT;
    signal n_bit : natural range 0 to 31;
    signal end_count : std_logic;
    signal data_reg : std_logic_vector(15 downto 0);


begin

    FREQ_DIV: process(clk)
    begin
        if rising_edge(clk) then
            if NRST = '0' then
                counter <= 1;
            else
                if n_bit < 16 then
                    if counter <  MAX_COUNT   then
                        counter <= counter + 1;
                    else
                        counter <= 0;
                    end if;
                end if;
            end if ;
        end if;
    end process FREQ_DIV;

    SIFT_REG: process(clk)
    begin
        if rising_edge(clk) then
            if NRST = '0' then
                n_bit <= 16;
            else
                if START = '1' then
                    n_bit <= 0;
                    data_reg <= DATA;
                elsif n_bit < 16 and end_count = '1' then
                    n_bit <= n_bit + 1;
                    data_reg <= data_reg(14 downto 0) & '0';
                end if;
            end if ;
        end if;
    end process SIFT_REG;

    end_count <= '1' when counter = 0 else '0';
    SDO <= data_reg(15);
    SCL <= '1' when counter >  MAX_COUNT / 2 and n_bit < 16 else '0';
    DONE <= '1' when n_bit > 15 else '0';

end architecture rtl;