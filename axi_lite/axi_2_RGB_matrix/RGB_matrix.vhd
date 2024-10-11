library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity RGB_matrix is
    generic(
        MAX_CNT     : natural := 20;
        DEBUG       : std_logic := '0'
    );
    port(
        CLK     : in    std_logic;
        NRST    : in    std_logic;
        DATA    : in    std_logic_vector(7 downto 0);
        N_ROW   : out   std_logic_vector(4 downto 0);
        N_COL   : out   std_logic_vector(5 downto 0);
        RGB0    : out   std_logic_vector(2 downto 0);
        RGB1    : out   std_logic_vector(2 downto 0);
        ADDR    : out   std_logic_vector(4 downto 0);
        LAT     : out   std_logic;
        CLOCK_O : out   std_logic;
        OE      : out   std_logic
    );
end entity RGB_matrix;

architecture rtl of RGB_matrix is
    signal clk_div       : unsigned(31 downto 0);
    signal clock_o_s     : std_logic;
    signal end_cnt       : std_logic;
    signal end_h_cnt     : std_logic;
    signal h_cnt         : unsigned(6 downto 0);
    signal v_cnt         : unsigned(5 downto 0);

begin

    process(clk, NRST)
    begin
        if NRST = '0' then
            clk_div <= (others => '0');
        elsif rising_edge(clk) then
            if clk_div < MAX_CNT - 1 then
                clk_div <= clk_div + 1;
            else
                clk_div <= (others => '0');
            end if;
        end if;
    end process;

    end_cnt <= '1' when clk_div = MAX_CNT - 1 else '0';

    process(clk, NRST)
    begin
        if NRST = '0' then
            h_cnt <= (others => '0');
        elsif rising_edge(clk) then
            if end_cnt = '1' then
                if h_cnt < 128 then
                    h_cnt <= h_cnt + 1;
                else
                    h_cnt <= (others => '0');
                end if;
            end if;
        end if;
    end process;

    end_h_cnt <= '1' when h_cnt = 64 and end_cnt = '1' else '0';

    process(clk, NRST)
    begin
        if NRST = '0' then
            v_cnt <= (others => '0');
        elsif rising_edge(clk) then
            if end_h_cnt = '1' then
                if v_cnt < 31 then
                    v_cnt <= v_cnt + 1;
                else
                    v_cnt <= (others => '0');
                end if;
            end if;
        end if;
    end process;

    clock_o_s <= '0' when clk_div < MAX_CNT / 2 else '1';
    
    CLOCK_O <= clock_o_s when h_cnt < 64 else '0';
    OE <= '0' when h_cnt > 65 else '1';
    LAT <= '1' when h_cnt = 64 else '0';
    ADDR <= STD_LOGIC_VECTOR(v_cnt(4 downto 0));

    RGB0    <=  STD_LOGIC_VECTOR(v_cnt(2 downto 0)) and STD_LOGIC_VECTOR(h_cnt(2 downto 0)) when DEBUG = '1' else
    DATA(2 downto 0);

    RGB1    <=  STD_LOGIC_VECTOR(v_cnt(2 downto 0)) or STD_LOGIC_VECTOR(h_cnt(2 downto 0)) when DEBUG = '1' else
    DATA(5 downto 3);

    N_COL <= STD_LOGIC_VECTOR(h_cnt(5 downto 0));
    N_ROW <= STD_LOGIC_VECTOR(v_cnt(4 downto 0) + 1);


end architecture rtl;