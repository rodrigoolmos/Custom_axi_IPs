library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_master_interface_controller is
    generic (

        C_M_AXI_ADDR_WIDTH    : integer    := 32;
        C_M_AXI_DATA_WIDTH    : integer    := 32

    );
    port (

        -- Initiate AXI transactions
        INIT_AXI_TXN    : in std_logic;
        INIT_AXI_RXN    : in std_logic;

        -- Asserts when AXI ready
        AXI_TX_READY    : out std_logic;
        AXI_RX_READY    : out std_logic;

        -- AXI interface
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
end axi_master_interface_controller;

architecture implementation of axi_master_interface_controller is

    type state is ( IDLE,  WRITE, READ);
    signal mst_exec_state  : state ;

    signal axi_awvalid    : std_logic;
    signal axi_wvalid    : std_logic;
    signal axi_arvalid    : std_logic;
    signal axi_rready    : std_logic;
    signal axi_bready    : std_logic;
    signal start_single_write    : std_logic;
    signal start_single_read    : std_logic;
    signal write_issued    : std_logic;
    signal read_issued    : std_logic;
    signal writes_done    : std_logic;
    signal reads_done    : std_logic;
    
    signal init_txn_ff    : std_logic;
    signal init_txn_ff2    : std_logic;
    signal init_txn_pulse    : std_logic;

    signal init_rxn_ff    : std_logic;
    signal init_rxn_ff2    : std_logic;
    signal init_rxn_pulse    : std_logic;

begin
    
    M_AXI_AWPROT    <= "000";
    M_AXI_AWVALID    <= axi_awvalid;
    M_AXI_WVALID    <= axi_wvalid;
    M_AXI_WSTRB    <= "1111";
    M_AXI_BREADY    <= axi_bready;
    M_AXI_ARVALID    <= axi_arvalid;
    M_AXI_ARPROT    <= "001";
    M_AXI_RREADY    <= axi_rready;
    AXI_TX_READY  <= '0' when mst_exec_state = WRITE or init_txn_ff = '1' or INIT_AXI_TXN = '1' else '1';
    AXI_RX_READY  <= '0' when mst_exec_state = READ or init_rxn_ff = '1' or INIT_AXI_RXN = '1' else '1';

    init_txn_pulse    <= ( not init_txn_ff2)  and  init_txn_ff;
    init_rxn_pulse    <= ( not init_rxn_ff2)  and  init_rxn_ff;

    process(M_AXI_ACLK)
    begin
        if (rising_edge (M_AXI_ACLK)) then
            if (M_AXI_ARESETN = '0' ) then
                init_txn_ff <= '0';
                init_txn_ff2 <= '0';
            else
                init_txn_ff <= INIT_AXI_TXN;
                init_txn_ff2 <= init_txn_ff;
            end if;
        end if;
    end process;

    process(M_AXI_ACLK)
    begin
        if (rising_edge (M_AXI_ACLK)) then
            if (M_AXI_ARESETN = '0' ) then
                init_rxn_ff <= '0';
                init_rxn_ff2 <= '0';
            else
                init_rxn_ff <= INIT_AXI_RXN;
                init_rxn_ff2 <= init_rxn_ff;
            end if;
        end if;
    end process;

    process(M_AXI_ACLK)
    begin
        if (rising_edge (M_AXI_ACLK)) then
            if (M_AXI_ARESETN = '0' or init_txn_pulse = '1') then
                axi_awvalid <= '0';
            else
                if (start_single_write = '1') then
                    axi_awvalid <= '1';
                elsif (M_AXI_AWREADY = '1' and axi_awvalid = '1') then
                    axi_awvalid <= '0';
                end if;
            end if;
        end if;
    end process;

    process(M_AXI_ACLK)
    begin
        if (rising_edge (M_AXI_ACLK)) then
            if (M_AXI_ARESETN = '0' or init_txn_pulse = '1' ) then
                axi_wvalid <= '0';
            else
                if (start_single_write = '1') then
                    axi_wvalid <= '1';
                elsif (M_AXI_WREADY = '1' and axi_wvalid = '1') then
                    axi_wvalid <= '0';
                end if;
            end if;
        end if;
    end process;

    process(M_AXI_ACLK)
    begin
        if (rising_edge (M_AXI_ACLK)) then
            if (M_AXI_ARESETN = '0' or init_txn_pulse = '1') then
                axi_bready <= '0';
            else
                if (M_AXI_BVALID = '1' and axi_bready = '0') then
                    axi_bready <= '1';
                elsif (axi_bready = '1') then
                    axi_bready <= '0';
                end if;
            end if;
        end if;
    end process;


    process(M_AXI_ACLK)
    begin
        if (rising_edge (M_AXI_ACLK)) then
            if (M_AXI_ARESETN = '0' or init_txn_pulse = '1') then
                axi_arvalid <= '0';
            else
                if (start_single_read = '1') then
                    axi_arvalid <= '1';
                elsif (M_AXI_ARREADY = '1' and axi_arvalid = '1') then
                    axi_arvalid <= '0';
                end if;
            end if;
        end if;
    end process;


    process(M_AXI_ACLK)
    begin
        if (rising_edge (M_AXI_ACLK)) then
            if (M_AXI_ARESETN = '0' or init_txn_pulse = '1') then
                axi_rready <= '1';
            else
                if (M_AXI_RVALID = '1' and axi_rready = '0') then
                    axi_rready <= '1';
                elsif (axi_rready = '1') then
                    axi_rready <= '0';
                end if;
            end if;
        end if;
    end process;
    

    MASTER_EXECUTION_PROC:process(M_AXI_ACLK)
    begin
        if (rising_edge (M_AXI_ACLK)) then
            if (M_AXI_ARESETN = '0' ) then

                mst_exec_state  <= IDLE;
                start_single_write <= '0';
                write_issued   <= '0';
                start_single_read  <= '0';
                read_issued  <= '0';
            else

                case (mst_exec_state) is
                    
                    when IDLE =>

                        if ( init_txn_pulse = '1') then
                            mst_exec_state  <= WRITE;
                        elsif ( init_rxn_pulse = '1') then
                            mst_exec_state  <= READ;
                        else
                            mst_exec_state  <= IDLE;
                        end if;
                        
                    when WRITE =>

                        if (writes_done = '1') then
                            mst_exec_state <= IDLE;
                        else
                            mst_exec_state  <= WRITE;
                            
                            if (axi_awvalid = '0' and axi_wvalid = '0' and M_AXI_BVALID = '0' and
                                start_single_write = '0' and write_issued = '0') then
                                start_single_write <= '1';
                                write_issued  <= '1';
                            elsif (axi_bready = '1') then
                                write_issued   <= '0';
                            else
                                start_single_write <= '0';
                            end if;
                        end if;
                        
                    when READ =>

                        if (reads_done = '1') then
                            mst_exec_state <= IDLE;
                        else
                            mst_exec_state  <= READ;
                            
                            if (axi_arvalid = '0' and M_AXI_RVALID = '0' and
                                start_single_read = '0' and read_issued = '0') then
                                start_single_read <= '1';
                                read_issued   <= '1';
                            elsif (axi_rready = '1') then
                                read_issued   <= '0';
                            else
                                start_single_read <= '0';
                            end if;
                        end if;
                        
                    when others  =>
                        mst_exec_state  <= IDLE;
                end case  ;
            end if;
        end if;
    end process;
    
    
    process(M_AXI_ACLK)
    begin
        if (rising_edge (M_AXI_ACLK)) then
            if (M_AXI_ARESETN = '0' or init_txn_pulse = '1') then
                writes_done <= '0';
            else
                if (M_AXI_BVALID = '1' and axi_bready = '1') then
                    writes_done <= '1';
                end if;
            end if;
        end if;
    end process;
    

    process(M_AXI_ACLK)
    begin
        if (rising_edge (M_AXI_ACLK)) then
            if (M_AXI_ARESETN = '0' or init_rxn_pulse = '1') then
                reads_done <= '0';
            else
                if (M_AXI_RVALID = '1' and axi_rready = '1') then
                    reads_done <= '1';
                end if;
            end if;
        end if;
    end process;
    

end implementation;