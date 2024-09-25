library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity top_design_uart_test_tb is
end entity top_design_uart_test_tb;

architecture rtl of top_design_uart_test_tb is
    
    constant period_time : time := 50000 ps; -- 20MHz
    constant baud_rate : natural := 921600;
    constant bite_time : time := 1000000 / baud_rate * 1 us;
    constant clk_tics_per_bit : natural := bite_time/period_time;
    signal   finished    : std_logic := '0';
    
    signal clk :        std_logic;
    signal nrst :       std_logic;
    signal m00_axi_init_axi_txn : std_logic;
    signal m00_axi_init_axi_rxn : std_logic;
    
    signal uart_tx: std_logic;
    signal uart_rx: std_logic;
    signal byte_tx_tmp :    std_logic_vector(7 downto 0);

    
    signal m00_axi_txn_ready : std_logic;
    signal m00_axi_rxn_ready : std_logic;
    
    signal test_wdata : std_logic_vector(31 downto 0);
    signal test_awaddr : std_logic_vector(31 downto 0);
    signal test_araddr : std_logic_vector(31 downto 0);
    signal test_rdata : std_logic_vector(31 downto 0);

    signal rx_byte_tb :     std_logic_vector(7 downto 0);
    type type_memory is array (0 to 255) of std_logic_vector(7 downto 0);
    signal memory_tb : type_memory;
    signal write_addres_tb   : natural range 0 to 512 := 0;
    
    component top_design_uart_test is
        generic(
            clk_tics_per_bit : integer := 6);
        port (
        ------------- debug from tb ----------
            test_wdata  : in std_logic_vector(31 downto 0);
            test_awaddr : in std_logic_vector(31 downto 0);
            test_araddr : in std_logic_vector(31 downto 0);
            test_rdata  : out std_logic_vector(31 downto 0);
            m00_axi_init_axi_txn : in STD_LOGIC;
            m00_axi_init_axi_rxn : in STD_LOGIC;
            m00_axi_txn_ready : out STD_LOGIC;
            m00_axi_rxn_ready : out STD_LOGIC;
        -------------------------------------
            
            uart_rx : in        std_logic;
            uart_tx : out       std_logic;
            
            clk : in STD_LOGIC;
            nrst : in STD_LOGIC

        );
    end component top_design_uart_test;
    
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
    
    test_axi_uart_tx: process
    begin
        nrst <= '0';
        m00_axi_init_axi_txn <= '0';
        m00_axi_init_axi_rxn <= '0';
        wait until rising_edge(clk);
        nrst <= '1';
        wait until rising_edge(clk);
        
        -- RX PART
        -- check empty works
        wait for 1 ms;
        wait until rising_edge(clk);
        m00_axi_init_axi_rxn <= '1';
        test_araddr <= x"0000000C";
        wait until rising_edge(clk);
        m00_axi_init_axi_rxn <= '0';
        wait until m00_axi_rxn_ready = '1';
        
        -- make 256 rx transactions from 0 to 255
        for i in 0 to 255 loop
            byte_tx_tmp <= std_logic_vector(to_unsigned(i, byte_tx_tmp'length));
            wait for 1 ps;
            simulate_tx(byte_tx_tmp, uart_rx);
        end loop;
        
        -- ckeck full works
        wait for 100 us;
        wait until rising_edge(clk);
        m00_axi_init_axi_rxn <= '1';
        test_araddr <= x"0000000C";
        wait until rising_edge(clk);
        m00_axi_init_axi_rxn <= '0';
        wait until m00_axi_rxn_ready = '1';
        wait for 100 us;
        
        -- read rx fifo
        for i in 0 to 255 loop
            wait until rising_edge(clk);
            m00_axi_init_axi_rxn <= '1';
            test_araddr <= x"00000008";
            wait until rising_edge(clk);
            m00_axi_init_axi_rxn <= '0';
            wait until m00_axi_rxn_ready = '1';
        end loop;
        
        -- check empty works
        wait for 100 us;
        wait until rising_edge(clk);
        m00_axi_init_axi_rxn <= '1';
        test_araddr <= x"0000000C";
        wait until rising_edge(clk);
        m00_axi_init_axi_rxn <= '0';
        wait until m00_axi_rxn_ready = '1';
        wait for 100 us;

        
        -- make 256 rx transactions from 0 to 255
        for i in 0 to 255 loop
            byte_tx_tmp <= std_logic_vector(to_unsigned(i, byte_tx_tmp'length));
            wait for 1 ps;
            simulate_tx(byte_tx_tmp, uart_rx);
        end loop;

        -- ckeck full works
        wait for 100 us;
        wait until rising_edge(clk);
        m00_axi_init_axi_rxn <= '1';
        test_araddr <= x"0000000C";
        wait until rising_edge(clk);
        m00_axi_init_axi_rxn <= '0';
        wait until m00_axi_rxn_ready = '1';
        wait for 100 us;
        
        -- read rx fifo
        for i in 0 to 255 loop
            wait until rising_edge(clk);
            m00_axi_init_axi_rxn <= '1';
            test_araddr <= x"00000008";
            wait until rising_edge(clk);
            m00_axi_init_axi_rxn <= '0';
            wait until m00_axi_rxn_ready = '1';
        end loop;
        
        -- check empty works
        wait for 100 us;
        wait until rising_edge(clk);
        m00_axi_init_axi_rxn <= '1';
        test_araddr <= x"0000000C";
        wait until rising_edge(clk);
        m00_axi_init_axi_rxn <= '0';
        wait until m00_axi_rxn_ready = '1';
        wait for 100 us;
        
        -- toggle rx transaction read axi fifo
        for i in 0 to 255 loop
            byte_tx_tmp <= std_logic_vector(to_unsigned(i, byte_tx_tmp'length));
            wait for 1 ps;
            simulate_tx(byte_tx_tmp, uart_rx);
            
            wait until rising_edge(clk);
            m00_axi_init_axi_rxn <= '1';
            test_araddr <= x"00000008";
            wait until rising_edge(clk);
            m00_axi_init_axi_rxn <= '0';
            wait until m00_axi_rxn_ready = '1';
        end loop;
        
        -- TX PART
        -- check empty works
        wait for 1000 us;
        wait until rising_edge(clk);
        m00_axi_init_axi_rxn <= '1';
        test_araddr <= x"00000004";
        wait until rising_edge(clk);
        m00_axi_init_axi_rxn <= '0';
        wait until m00_axi_rxn_ready = '1';
        
        for i in 0 to 255 loop

            m00_axi_init_axi_txn <= '1';
            test_wdata <= std_logic_vector(to_unsigned(i + 11, test_wdata'length));
            test_awaddr <= x"00000000";
            wait until rising_edge(clk);
            m00_axi_init_axi_txn <= '0';
            wait until m00_axi_txn_ready = '1';

            loop
                m00_axi_init_axi_rxn <= '1';
                test_araddr <= x"00000004";
                wait until rising_edge(clk);
                m00_axi_init_axi_rxn <= '0';
                wait until m00_axi_rxn_ready = '1';
                exit when (test_rdata(1) = '0');
            end loop;
        end loop;
        
        wait for 10 ms;
        wait until rising_edge(clk);

        
        for i in 0 to 255 loop

            m00_axi_init_axi_txn <= '1';
            test_wdata <= std_logic_vector(to_unsigned(i + 10, test_wdata'length));
            test_awaddr <= x"00000000";
            wait until rising_edge(clk);
            m00_axi_init_axi_txn <= '0';
            wait until m00_axi_txn_ready = '1';

            loop
                m00_axi_init_axi_rxn <= '1';
                test_araddr <= x"00000004";
                wait until rising_edge(clk);
                m00_axi_init_axi_rxn <= '0';
                wait until m00_axi_rxn_ready = '1';
                exit when (test_rdata(1) = '0');
            end loop;
        end loop;
        
        wait for 10 ms;
        
        m00_axi_init_axi_txn <= '1';
        test_wdata <= std_logic_vector(to_unsigned(20, test_wdata'length));
        test_awaddr <= x"00000000";
        wait until rising_edge(clk);
        m00_axi_init_axi_txn <= '0';
        wait until m00_axi_txn_ready = '1';
        wait for 100 us;

        
        m00_axi_init_axi_txn <= '1';
        test_wdata <= std_logic_vector(to_unsigned(30, test_wdata'length));
        test_awaddr <= x"00000000";
        wait until rising_edge(clk);
        m00_axi_init_axi_txn <= '0';
        wait until m00_axi_txn_ready = '1';
        wait for 100 us;

        
        m00_axi_init_axi_txn <= '1';
        test_wdata <= std_logic_vector(to_unsigned(40, test_wdata'length));
        test_awaddr <= x"00000000";
        wait until rising_edge(clk);
        m00_axi_init_axi_txn <= '0';
        wait until m00_axi_txn_ready = '1';
        wait for 100 us;
        
        m00_axi_init_axi_txn <= '1';
        test_wdata <= std_logic_vector(to_unsigned(50, test_wdata'length));
        test_awaddr <= x"00000000";
        wait until rising_edge(clk);
        m00_axi_init_axi_txn <= '0';
        wait until m00_axi_txn_ready = '1';
        wait for 100 us;

        
        m00_axi_init_axi_txn <= '1';
        test_wdata <= std_logic_vector(to_unsigned(60, test_wdata'length));
        test_awaddr <= x"00000000";
        wait until rising_edge(clk);
        m00_axi_init_axi_txn <= '0';
        wait until m00_axi_txn_ready = '1';
        wait for 100 us;

        
        m00_axi_init_axi_txn <= '1';
        test_wdata <= std_logic_vector(to_unsigned(70, test_wdata'length));
        test_awaddr <= x"00000000";
        wait until rising_edge(clk);
        m00_axi_init_axi_txn <= '0';
        wait until m00_axi_txn_ready = '1';
        wait for 100 us;

        loop
            m00_axi_init_axi_rxn <= '1';
            test_araddr <= x"00000004";
            wait until rising_edge(clk);
            m00_axi_init_axi_rxn <= '0';
            wait until m00_axi_rxn_ready = '1';
            exit when (test_rdata(1) = '0');
        end loop;
        wait for 100 us;
        
        m00_axi_init_axi_txn <= '1';
        test_wdata <= std_logic_vector(to_unsigned(11, test_wdata'length));
        test_awaddr <= x"00000000";
        wait until rising_edge(clk);
        m00_axi_init_axi_txn <= '0';
        wait until m00_axi_txn_ready = '1';
        wait for 100 us;

        loop
            m00_axi_init_axi_rxn <= '1';
            test_araddr <= x"00000004";
            wait until rising_edge(clk);
            m00_axi_init_axi_rxn <= '0';
            wait until m00_axi_rxn_ready = '1';
            exit when (test_rdata(1) = '0');
        end loop;
        wait for 100 us;
        
        m00_axi_init_axi_txn <= '1';
        test_wdata <= std_logic_vector(to_unsigned(22, test_wdata'length));
        test_awaddr <= x"00000000";
        wait until rising_edge(clk);
        m00_axi_init_axi_txn <= '0';
        wait until m00_axi_txn_ready = '1';
        wait for 100 us;

        loop
            m00_axi_init_axi_rxn <= '1';
            test_araddr <= x"00000004";
            wait until rising_edge(clk);
            m00_axi_init_axi_rxn <= '0';
            wait until m00_axi_rxn_ready = '1';
            exit when (test_rdata(1) = '0');
        end loop;
        
        m00_axi_init_axi_txn <= '1';
        test_wdata <= std_logic_vector(to_unsigned(33, test_wdata'length));
        test_awaddr <= x"00000000";
        wait until rising_edge(clk);
        m00_axi_init_axi_txn <= '0';
        wait until m00_axi_txn_ready = '1';
        
        m00_axi_init_axi_txn <= '1';
        test_wdata <= std_logic_vector(to_unsigned(44, test_wdata'length));
        test_awaddr <= x"00000000";
        wait until rising_edge(clk);
        m00_axi_init_axi_txn <= '0';
        wait until m00_axi_txn_ready = '1';
        
        m00_axi_init_axi_txn <= '1';
        test_wdata <= std_logic_vector(to_unsigned(55, test_wdata'length));
        test_awaddr <= x"00000000";
        wait until rising_edge(clk);
        m00_axi_init_axi_txn <= '0';
        wait until m00_axi_txn_ready = '1';
        
        m00_axi_init_axi_txn <= '1';
        test_wdata <= std_logic_vector(to_unsigned(66, test_wdata'length));
        test_awaddr <= x"00000000";
        wait until rising_edge(clk);
        m00_axi_init_axi_txn <= '0';
        wait until m00_axi_txn_ready = '1';
        
        m00_axi_init_axi_txn <= '1';
        test_wdata <= std_logic_vector(to_unsigned(77, test_wdata'length));
        test_awaddr <= x"00000000";
        wait until rising_edge(clk);
        m00_axi_init_axi_txn <= '0';
        wait until m00_axi_txn_ready = '1';
        
        m00_axi_init_axi_txn <= '1';
        test_wdata <= std_logic_vector(to_unsigned(88, test_wdata'length));
        test_awaddr <= x"00000000";
        wait until rising_edge(clk);
        m00_axi_init_axi_txn <= '0';
        wait until m00_axi_txn_ready = '1';
        
        m00_axi_init_axi_txn <= '1';
        test_wdata <= std_logic_vector(to_unsigned(99, test_wdata'length));
        test_awaddr <= x"00000000";
        wait until rising_edge(clk);
        m00_axi_init_axi_txn <= '0';
        wait until m00_axi_txn_ready = '1';

        loop
            m00_axi_init_axi_rxn <= '1';
            test_araddr <= x"00000004";
            wait until rising_edge(clk);
            m00_axi_init_axi_rxn <= '0';
            wait until m00_axi_rxn_ready = '1';
            exit when (test_rdata(1) = '0');
        end loop;
        
        wait for 10 ms;
        finished <= '1';
        wait;
    end process test_axi_uart_tx;

    
    
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
            memory_tb(write_addres_tb) <= rx_byte_tb;
            write_addres_tb <= write_addres_tb + 1;
            if write_addres_tb > 254 then
                write_addres_tb <= 0;
                wait for bite_time ;
                wait for 100 us;
                for item in 0 to 255 loop
                    memory_tb(item) <= (others => '0');
                end loop;
            end if;
        end loop;

        wait;
    end process rx_proc;
    
    u1: top_design_uart_test
    generic map(
        clk_tics_per_bit => clk_tics_per_bit)
    port map
    (
        ------------- debug from tb ----------
        test_wdata  => test_wdata,
        test_awaddr => test_awaddr,
        test_araddr => test_araddr,
        test_rdata  => test_rdata,
        m00_axi_init_axi_txn => m00_axi_init_axi_txn,
        m00_axi_init_axi_rxn => m00_axi_init_axi_rxn,
        m00_axi_txn_ready => m00_axi_txn_ready,
        m00_axi_rxn_ready => m00_axi_rxn_ready,
        --------------------------------------

        uart_rx => uart_rx,
        uart_tx => uart_tx,
        
        clk => clk,
        nrst => nrst


    );

end architecture rtl;