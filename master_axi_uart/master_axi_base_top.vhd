library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity master_axi_base_top is
    generic (
        clk_tics_per_bit : integer := 6;
        C_M00_AXI_ADDR_WIDTH    : integer    := 32;
        C_M00_AXI_DATA_WIDTH    : integer    := 32
    );
    port (
        
        uart_rx : in        std_logic;
        uart_tx : out       std_logic;
        
        ------------- AXI INTERFACE -------------------
        m00_axi_araddr    : out std_logic_vector(C_M00_AXI_ADDR_WIDTH-1 downto 0); -- AXI ADDRES READ
        m00_axi_awaddr    : out std_logic_vector(C_M00_AXI_ADDR_WIDTH-1 downto 0); -- AXI ADDRES WRITE
        m00_axi_wdata    : out std_logic_vector(C_M00_AXI_DATA_WIDTH-1 downto 0);  -- AXI DATA WRITTE
        m00_axi_rdata    : in std_logic_vector(C_M00_AXI_DATA_WIDTH-1 downto 0);   -- AXI DATA READ

        m00_axi_aclk        : in std_logic;
        m00_axi_aresetn    : in std_logic;
        m00_axi_awprot    : out std_logic_vector(2 downto 0);
        m00_axi_awvalid    : out std_logic;
        m00_axi_awready    : in std_logic;
        m00_axi_wstrb    : out std_logic_vector(C_M00_AXI_DATA_WIDTH/8-1 downto 0);
        m00_axi_wvalid    : out std_logic;
        m00_axi_wready    : in std_logic;
        m00_axi_bresp    : in std_logic_vector(1 downto 0);
        m00_axi_bvalid    : in std_logic;
        m00_axi_bready    : out std_logic;
        m00_axi_arprot    : out std_logic_vector(2 downto 0);
        m00_axi_arvalid    : out std_logic;
        m00_axi_arready    : in std_logic;
        m00_axi_rresp    : in std_logic_vector(1 downto 0);
        m00_axi_rvalid    : in std_logic;
        m00_axi_rready    : out std_logic
    );
end master_axi_base_top;

architecture arch_imp of master_axi_base_top is
    ----------------------------------------------------------------------
    -- Add user signals here
    -- use example
    
    signal byte_ready :     std_logic;
    signal start_tx :       std_logic;
    signal done_tx :        std_logic;
    signal byte_rx :        std_logic_vector(7 downto 0);
    signal byte_tx :        std_logic_vector(7 downto 0);
    
    signal cnt_byte : natural range 0 to 7;

    type t_State is (idle, reciving_addr, ope_type, reciving_data, fetching_data_axi, sending_data_axi,
            sending_data, prepare_uart, nop);
        signal State_axi : t_State;
        

        
        signal axi_data: std_logic_vector(C_M00_AXI_DATA_WIDTH-1 downto 0);
        signal axi_addr: std_logic_vector(C_M00_AXI_ADDR_WIDTH-1 downto 0);
        
    -- User logic ends
    ----------------------------------------------------------------------


        
        signal m00_axi_init_axi_txn : std_logic;
        signal m00_axi_init_axi_rxn : std_logic;
        signal m00_axi_txn_ready : std_logic;
        signal m00_axi_rxn_ready : std_logic;
        

        component axi_master_interface_controller is
            generic (
                C_M_AXI_ADDR_WIDTH    : integer    := 32;
                C_M_AXI_DATA_WIDTH    : integer    := 32
            );
            port (
            -------------------- CONTROL SIGNALS --------------------
                
--            TO MAKE A TRANSMISSION BY AXI, WRITE THE DATA TO TRANSMIT IN m00_axi_wdata THE ADDRESS TO
--            TRANSMIT TO IN m00_axi_awaddr AND GENERATE A HIGH LEVEL PULSE IN INIT_AXI_TXN WHEN THE
--            TRANSMISSION IS FINISHED AXI_TX_READY WILL BE SET TO 1
                
                INIT_AXI_TXN    : in std_logic; -- STARTS A TRANSMISSION ON THE RISING EDGE A NEW TRANSMISSION CANNOT BE MADE UNTIL AXI_TX_READY = 1.
                                                    -- The signal cannot be held indefinitely at 1 otherwise AXI_TX_READY will never confirm the end of the transmission,
                                                    -- a pulse of ideally 1 clock cycle must be generated.
                                                    -- the signal needs to be released with a 0 to complete the transmission.
                
--            TO MAKE A RECEIPT BY AXI YOU MUST WRITE THE ADDRESS I WANT TO RECEIVE FROM INTO
--            m00_axi_aRaddr AND GENERATE A HIGH LEVEL PULSE IN INIT_AXI_RXN WHEN THE TRANSMISSION
--            IS COMPLETED AXI_RX_READY WILL SET TO 1
                
                INIT_AXI_RXN    : in std_logic;  --STARTS A RECEPTION  ON THE RISING EDGE A NEW RECEPTION  CANNOT BE MADE UNTIL AXI_RX_READY = 1.
                                                     -- The signal cannot be held indefinitely at 1 otherwise AXI_RX_READY will never confirm the end of the transmission,
                                                     -- a pulse of ideally 1 clock cycle must be generated.
                                                     -- the signal needs to be released with a 0 to complete the transmission.

                AXI_TX_READY    : out std_logic; -- '1' IF AVAILABLE TO MAKE A TRANSMISSION '0' OTHERWISE
                AXI_RX_READY    : out std_logic; -- '1' IF AVAILABLE TO PERFORM A RECEPTION '0' OTHERWISE
            ---------------------------------------------------------
                
            ------------- AXI INTERFACE -------------------
                M_AXI_ACLK    : in std_logic;
                M_AXI_ARESETN    : in std_logic;
                M_AXI_AWPROT    : out std_logic_vector(2 downto 0);
                M_AXI_AWVALID    : out std_logic;
                M_AXI_AWREADY    : in std_logic;
                M_AXI_WSTRB    : out std_logic_vector(C_M_AXI_DATA_WIDTH/8-1 downto 0);
                M_AXI_WVALID    : out std_logic;
                M_AXI_WREADY    : in std_logic;
                M_AXI_BRESP    : in std_logic_vector(1 downto 0);
                M_AXI_BVALID    : in std_logic;
                M_AXI_BREADY    : out std_logic;
                M_AXI_ARPROT    : out std_logic_vector(2 downto 0);
                M_AXI_ARVALID    : out std_logic;
                M_AXI_ARREADY    : in std_logic;
                M_AXI_RRESP    : in std_logic_vector(1 downto 0);
                M_AXI_RVALID    : in std_logic;
                M_AXI_RREADY    : out std_logic
            );
        end component axi_master_interface_controller;

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
        
    begin

        master_test_v1_0_M00_AXI_inst : axi_master_interface_controller
        generic map (
            C_M_AXI_ADDR_WIDTH    => C_M00_AXI_ADDR_WIDTH,
            C_M_AXI_DATA_WIDTH    => C_M00_AXI_DATA_WIDTH
        )
        port map (
        -------------------- CONTROL SIGNALS --------------------

            INIT_AXI_TXN    => m00_axi_init_axi_txn,
            INIT_AXI_RXN    => m00_axi_init_axi_rxn,
            AXI_TX_READY    => m00_axi_txn_ready,
            AXI_RX_READY    => m00_axi_rxn_ready,
            
        -------------------- AXI INTERFACE --------------------
            M_AXI_ACLK    => m00_axi_aclk,
            M_AXI_ARESETN    => m00_axi_aresetn,
            M_AXI_AWPROT    => m00_axi_awprot,
            M_AXI_AWVALID    => m00_axi_awvalid,
            M_AXI_AWREADY    => m00_axi_awready,
            M_AXI_WSTRB    => m00_axi_wstrb,
            M_AXI_WVALID    => m00_axi_wvalid,
            M_AXI_WREADY    => m00_axi_wready,
            M_AXI_BRESP    => m00_axi_bresp,
            M_AXI_BVALID    => m00_axi_bvalid,
            M_AXI_BREADY    => m00_axi_bready,
            M_AXI_ARPROT    => m00_axi_arprot,
            M_AXI_ARVALID    => m00_axi_arvalid,
            M_AXI_ARREADY    => m00_axi_arready,
            M_AXI_RRESP    => m00_axi_rresp,
            M_AXI_RVALID    => m00_axi_rvalid,
            M_AXI_RREADY    => m00_axi_rready
        );


    ----------------------------------------------------------------------
    -- Add user logic here
    --    use example
        
        process (m00_axi_aclk)
        begin
            if rising_edge(m00_axi_aclk) then
                if m00_axi_aresetn = '0' then
                    State_axi <= idle;
                    start_tx <= '0';
                    byte_tx <= (others => '0');
                    axi_addr <= (others => '0');
                    axi_data <= (others => '0');
                    cnt_byte <= 0;
                else
                    case State_axi is
                        when idle =>
                            cnt_byte <= 0;
                            m00_axi_init_axi_txn <= '0';
                            m00_axi_init_axi_rxn <= '0';

                            if byte_ready = '1' then
                                cnt_byte <= cnt_byte + 1;
                                State_axi <= reciving_addr;
                                axi_addr <= axi_addr(C_M00_AXI_ADDR_WIDTH-9 downto 0) & byte_rx;
                            end if;
                        when reciving_addr =>
                            if byte_ready = '1' then
                                cnt_byte <= cnt_byte + 1;
                                axi_addr <= axi_addr(C_M00_AXI_ADDR_WIDTH-9 downto 0) & byte_rx;
                                if cnt_byte = 3 then
                                    State_axi <= ope_type;
                                    cnt_byte <= 0;
                                end if;
                            end if;
                        when ope_type =>
                            if byte_ready = '1' then
                                if byte_rx(0) = '0' then
                                    State_axi <= reciving_data;
                                else
                                    if m00_axi_rxn_ready = '1' then
                                        State_axi <= fetching_data_axi;
                                        m00_axi_araddr <= axi_addr;
                                        m00_axi_init_axi_rxn <= '1';
                                    end if;
                                end if;
                            end if;
                        when reciving_data =>
                            if byte_ready = '1' then

                                if cnt_byte < 3 then
                                    cnt_byte <= cnt_byte + 1;
                                    axi_data <= axi_data(C_M00_AXI_DATA_WIDTH-9 downto 0) & byte_rx;
                                else
                                    axi_data <= axi_data(C_M00_AXI_DATA_WIDTH-9 downto 0) & byte_rx;
                                    cnt_byte <= 0;
                                    if m00_axi_txn_ready = '1' then
                                        State_axi <= sending_data_axi;
                                    end if;
                                end if;
                            end if;
                        when sending_data_axi =>
                            m00_axi_wdata <= axi_data;
                            m00_axi_awaddr <= axi_addr;
                            m00_axi_init_axi_txn <= '1';
                            State_axi <= idle;
                            
                        when fetching_data_axi =>
                            m00_axi_init_axi_rxn <= '0';
                            if m00_axi_rxn_ready = '1' then
                                State_axi <= prepare_uart;
                                axi_data <= m00_axi_rdata;
                            end if;
                        when prepare_uart =>
                            start_tx <= '1';
                            cnt_byte <= cnt_byte + 1;
                            axi_data <= axi_data(C_M00_AXI_DATA_WIDTH - 9 downto 0) & x"00";
                            byte_tx <= axi_data(C_M00_AXI_DATA_WIDTH - 1 downto C_M00_AXI_DATA_WIDTH - 8);
                            State_axi <= nop;
                        when nop =>
                            State_axi <= sending_data;

                        when sending_data =>
                            if done_tx = '1' then
                                if cnt_byte < 3 then
                                    cnt_byte <= cnt_byte + 1;
                                    axi_data <= axi_data(C_M00_AXI_DATA_WIDTH - 9 downto 0) & x"00";
                                    byte_tx <= axi_data(C_M00_AXI_DATA_WIDTH - 1 downto C_M00_AXI_DATA_WIDTH - 8);
                                else
                                    start_tx <= '0';
                                    byte_tx <= axi_data(C_M00_AXI_DATA_WIDTH - 1 downto C_M00_AXI_DATA_WIDTH - 8);
                                    State_axi <= idle;
                                    cnt_byte <= 0;
                                end if;
                            end if;

                        when others =>
                            
                    end case;
                    
                end if;
            end if;
        end process;
        
        uart_interface: uart
        generic map(
            clk_tics_per_bit => clk_tics_per_bit)
        port map
        (
            clk => m00_axi_aclk,
            nrst => m00_axi_aresetn,
            uart_rx => uart_rx,
            uart_tx => uart_tx,
            byte_ready => byte_ready,
            start_tx => start_tx,
            done_tx => done_tx,
            byte_rx => byte_rx,
            byte_tx => byte_tx
        );
        
    -- User logic ends
    ----------------------------------------------------------------------

    end arch_imp;
