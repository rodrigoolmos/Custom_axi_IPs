library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity design_top_tb is
end entity design_top_tb;

architecture rtl of design_top_tb is
    
    constant period_time : time := 83333 ps; -- 12MHz
    constant baud_rate : natural := 9600;
    constant bite_time : time := 1000000 / baud_rate * 1 us;
    constant clk_tics_per_bit : natural := bite_time/period_time;
    
    signal   finished    : std_logic := '0';
    
    signal clk :        std_logic;
    signal nrst :       std_logic;
    signal uart_rx :        std_logic;
    signal uart_tx :        std_logic;
    
    type type_memory is array (0 to 3) of std_logic_vector(7 downto 0);
    signal memory : type_memory;
    signal rx_byte_tb :     std_logic_vector(7 downto 0);
    signal k: natural range 0 to 7;
    
    component design_top is
        generic (
            clk_tics_per_bit : integer := 6;
            C_M00_AXI_ADDR_WIDTH    : integer    := 32;
            C_M00_AXI_DATA_WIDTH    : integer    := 32
        );
        port (
            uart_rx : in        std_logic;
            uart_tx : out       std_logic;
            
            clk : in STD_LOGIC;
            nrst : in STD_LOGIC

        );
    end component design_top;
    
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
    
    procedure send_frame(
        constant addr         : in std_logic_vector(31 downto 0);
        constant w_r           : in std_logic_vector(7 downto 0);
        constant data         : in std_logic_vector(31 downto 0);
        signal rx             : out std_logic
    ) is
    begin

        -- write addr
        wait for 1 ps;
        simulate_tx(addr(31 downto 24), rx);
        wait for 1 ps;
        simulate_tx(addr(23 downto 16), rx);
        wait for 1 ps;
        simulate_tx(addr(15 downto 8), rx);
        wait for 1 ps;
        simulate_tx(addr(7 downto 0), rx);
        
        -- op type
        wait for 1 ps;
        simulate_tx(w_r(7 downto 0), rx);
        
        if w_r(0) = '0' then
            -- write data
            wait for 1 ps;
            simulate_tx(data(31 downto 24), rx);
            wait for 1 ps;
            simulate_tx(data(23 downto 16), rx);
            wait for 1 ps;
            simulate_tx(data(15 downto 8), rx);
            wait for 1 ps;
            simulate_tx(data(7 downto 0), rx);
            
        else
            -- read data
            wait for bite_time * 40 ;
        end if;


        
    end procedure;
    
    
begin


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
    
    process
    begin
        nrst <= '0';
        uart_rx <= '0';
        wait until rising_edge(clk);
        nrst <= '1';
        wait for 10 us;
        wait until rising_edge(clk);
        
        -- write 4 regs
        send_frame(x"12345670", x"00", x"BADC0FFE", uart_rx);
        send_frame(x"12345674", x"00", x"B16B00B5", uart_rx);
        send_frame(x"12345678", x"00", x"DEADBEEF", uart_rx);
        send_frame(x"1234567C", x"00", x"D15600D5", uart_rx);

        wait for 5 ms;
        
        -- read 4 regs
        send_frame(x"12345670", x"01", x"00000000", uart_rx);
        send_frame(x"12345674", x"01", x"00000000", uart_rx);
        send_frame(x"12345678", x"01", x"00000000", uart_rx);
        send_frame(x"1234567C", x"01", x"00000000", uart_rx);



        wait for 3 ms;
        finished <= '1';
        wait;
    end process;
    rx_proc: process

    begin
        k <= 0;
        while finished /= '1' loop

            wait until uart_tx = '0';
            wait for 3*bite_time/2;
            for i in 0 to 7 loop
                rx_byte_tb(i) <= uart_tx;
                wait for bite_time ;
            end loop;
            wait for bite_time/2 ;
            memory(k) <= rx_byte_tb;
            k <= k + 1;
            if k = 3 then
                k <= 0;
            end if;
        end loop;

        wait;
    end process rx_proc;

    u1: design_top
    generic map(
        clk_tics_per_bit => clk_tics_per_bit,
        C_M00_AXI_ADDR_WIDTH => 32,
        C_M00_AXI_DATA_WIDTH => 32)
    port map
    (
        uart_rx => uart_rx,
        uart_tx => uart_tx,
        
        clk => clk,
        nrst => nrst


    );

end architecture rtl;