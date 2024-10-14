library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bram is
  generic (
    ADDR_WIDTH : integer := 10; -- Ancho de la dirección
    DATA_WIDTH : integer := 8    -- Ancho de los datos
  );
  port (
    CLKA    : in std_logic;
    CLKB    : in std_logic;
    ENA     : in std_logic;
    ENB     : in std_logic;
    WE_A    : in  std_logic;                      
    WE_B    : in  std_logic;                      
    DIN_A   : in  std_logic_vector(DATA_WIDTH-1 downto 0); 
    DIN_B   : in  std_logic_vector(DATA_WIDTH-1 downto 0); 
    ADDR_A  : in  std_logic_vector(ADDR_WIDTH-1 downto 0); 
    ADDR_B  : in  std_logic_vector(ADDR_WIDTH-1 downto 0); 
    DOUT_A  : out std_logic_vector(DATA_WIDTH-1 downto 0); 
    DOUT_B  : out std_logic_vector(DATA_WIDTH-1 downto 0)  
  );
end bram;

architecture Behavioral of bram is
  type mem_array is array (natural range 0 to 2**ADDR_WIDTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
  shared variable mem : mem_array;
  
begin

   -- port A
    process (CLKA)
    begin
        if rising_edge(CLKA) then
            if ENA = '1' then
                if WE_A = '1' then
                    mem(to_integer(unsigned(ADDR_A))) := DIN_A;
                end if;
                DOUT_A <= mem(to_integer(unsigned(ADDR_A)));
            end if;
        end if;
    end process;


    -- port B
    process (CLKB)
    begin
        if rising_edge(CLKB) then
            if ENB = '1' then
                if WE_B = '1' then
                    mem(to_integer(unsigned(ADDR_B))) := DIN_B;
                end if;
                DOUT_B <= mem(to_integer(unsigned(ADDR_B)));
            end if;
        end if;
    end process;
  
  
end Behavioral;

