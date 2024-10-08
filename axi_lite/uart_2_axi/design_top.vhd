library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity design_top is
    generic (
        clk_tics_per_bit : integer := 6;
        C_M00_AXI_ADDR_WIDTH    : integer    := 32;
        C_M00_AXI_DATA_WIDTH    : integer    := 32
    );
    port (
        ------------- debug from tb ----------
--        test_wdata  : in std_logic_vector(31 downto 0);
--        test_awaddr : in std_logic_vector(31 downto 0);
--        test_araddr : in std_logic_vector(31 downto 0);
--        test_rdata  : out std_logic_vector(31 downto 0);
--        m00_axi_init_axi_txn : in STD_LOGIC;
--        m00_axi_init_axi_rxn : in STD_LOGIC;
--        m00_axi_txn_ready : out STD_LOGIC;
--        m00_axi_rxn_ready : out STD_LOGIC;
        -------------------------------------
        uart_rx : in        std_logic;
        uart_tx : out       std_logic;
        
        clk : in STD_LOGIC;
        nrst : in STD_LOGIC
    );
end entity design_top;

architecture rtl of design_top is
    component axi_lite_top is
        port (
            
            s00_axi_awaddr : in STD_LOGIC_VECTOR ( 3 downto 0 );
            s00_axi_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
            s00_axi_awvalid : in STD_LOGIC;
            s00_axi_awready : out STD_LOGIC;
            s00_axi_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
            s00_axi_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
            s00_axi_wvalid : in STD_LOGIC;
            s00_axi_wready : out STD_LOGIC;
            s00_axi_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
            s00_axi_bvalid : out STD_LOGIC;
            s00_axi_bready : in STD_LOGIC;
            s00_axi_araddr : in STD_LOGIC_VECTOR ( 3 downto 0 );
            s00_axi_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
            s00_axi_arvalid : in STD_LOGIC;
            s00_axi_arready : out STD_LOGIC;
            s00_axi_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
            s00_axi_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
            s00_axi_rvalid : out STD_LOGIC;
            s00_axi_rready : in STD_LOGIC;
            s00_axi_aclk : in STD_LOGIC;
            s00_axi_aresetn : in STD_LOGIC
        );
    end component axi_lite_top;
    
    component master_axi_base_top is
        generic (
            clk_tics_per_bit : integer := 6;
            C_M00_AXI_ADDR_WIDTH    : integer    := 32;
            C_M00_AXI_DATA_WIDTH    : integer    := 32
        );
        port (
            uart_rx : in        std_logic;
            uart_tx : out       std_logic;
            
            m00_axi_aclk : in STD_LOGIC;
            m00_axi_aresetn : in STD_LOGIC;
            m00_axi_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
            m00_axi_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
            m00_axi_awvalid : out STD_LOGIC;
            m00_axi_awready : in STD_LOGIC;
            m00_axi_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
            m00_axi_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
            m00_axi_wvalid : out STD_LOGIC;
            m00_axi_wready : in STD_LOGIC;
            m00_axi_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
            m00_axi_bvalid : in STD_LOGIC;
            m00_axi_bready : out STD_LOGIC;
            m00_axi_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
            m00_axi_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
            m00_axi_arvalid : out STD_LOGIC;
            m00_axi_arready : in STD_LOGIC;
            m00_axi_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
            m00_axi_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
            m00_axi_rvalid : in STD_LOGIC;
            m00_axi_rready : out STD_LOGIC
        );
    end component master_axi_base_top;

    signal master_test_0_M00_AXI_ARADDR : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal master_test_0_M00_AXI_ARPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
    signal master_test_0_M00_AXI_ARREADY : STD_LOGIC;
    signal master_test_0_M00_AXI_ARVALID : STD_LOGIC;
    signal master_test_0_M00_AXI_AWADDR : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal master_test_0_M00_AXI_AWPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
    signal master_test_0_M00_AXI_AWREADY : STD_LOGIC;
    signal master_test_0_M00_AXI_AWVALID : STD_LOGIC;
    signal master_test_0_M00_AXI_BREADY : STD_LOGIC;
    signal master_test_0_M00_AXI_BRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
    signal master_test_0_M00_AXI_BVALID : STD_LOGIC;
    signal master_test_0_M00_AXI_RDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal master_test_0_M00_AXI_RREADY : STD_LOGIC;
    signal master_test_0_M00_AXI_RRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
    signal master_test_0_M00_AXI_RVALID : STD_LOGIC;
    signal master_test_0_M00_AXI_WDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal master_test_0_M00_AXI_WREADY : STD_LOGIC;
    signal master_test_0_M00_AXI_WSTRB : STD_LOGIC_VECTOR ( 3 downto 0 );
    signal master_test_0_M00_AXI_WVALID : STD_LOGIC;
    signal master_test_0_m00_axi_error : STD_LOGIC;
    
begin
    
    master_test_0: component master_axi_base_top
    generic map(
        clk_tics_per_bit => clk_tics_per_bit,
        C_M00_AXI_ADDR_WIDTH => C_M00_AXI_ADDR_WIDTH,
        C_M00_AXI_DATA_WIDTH => C_M00_AXI_DATA_WIDTH)
    port map (
        
        uart_rx => uart_rx,
        uart_tx => uart_tx,
        
        m00_axi_aclk => clk,
        m00_axi_araddr(31 downto 0) => master_test_0_M00_AXI_ARADDR(31 downto 0),
        m00_axi_aresetn => nrst,
        m00_axi_arprot(2 downto 0) => master_test_0_M00_AXI_ARPROT(2 downto 0),
        m00_axi_arready => master_test_0_M00_AXI_ARREADY,
        m00_axi_arvalid => master_test_0_M00_AXI_ARVALID,
        m00_axi_awaddr(31 downto 0) => master_test_0_M00_AXI_AWADDR(31 downto 0),
        m00_axi_awprot(2 downto 0) => master_test_0_M00_AXI_AWPROT(2 downto 0),
        m00_axi_awready => master_test_0_M00_AXI_AWREADY,
        m00_axi_awvalid => master_test_0_M00_AXI_AWVALID,
        m00_axi_bready => master_test_0_M00_AXI_BREADY,
        m00_axi_bresp(1 downto 0) => master_test_0_M00_AXI_BRESP(1 downto 0),
        m00_axi_bvalid => master_test_0_M00_AXI_BVALID,
        m00_axi_rdata(31 downto 0) => master_test_0_M00_AXI_RDATA(31 downto 0),
        m00_axi_rready => master_test_0_M00_AXI_RREADY,
        m00_axi_rresp(1 downto 0) => master_test_0_M00_AXI_RRESP(1 downto 0),
        m00_axi_rvalid => master_test_0_M00_AXI_RVALID,
        m00_axi_wdata(31 downto 0) => master_test_0_M00_AXI_WDATA(31 downto 0),
        m00_axi_wready => master_test_0_M00_AXI_WREADY,
        m00_axi_wstrb(3 downto 0) => master_test_0_M00_AXI_WSTRB(3 downto 0),
        m00_axi_wvalid => master_test_0_M00_AXI_WVALID
    );
    
    slave_lite_tb_0: component axi_lite_top
    port map (
        s00_axi_aclk => clk,
        s00_axi_araddr(3 downto 0) => master_test_0_M00_AXI_ARADDR(3 downto 0),
        s00_axi_aresetn => nrst,
        s00_axi_arprot(2 downto 0) => master_test_0_M00_AXI_ARPROT(2 downto 0),
        s00_axi_arready => master_test_0_M00_AXI_ARREADY,
        s00_axi_arvalid => master_test_0_M00_AXI_ARVALID,
        s00_axi_awaddr(3 downto 0) => master_test_0_M00_AXI_AWADDR(3 downto 0),
        s00_axi_awprot(2 downto 0) => master_test_0_M00_AXI_AWPROT(2 downto 0),
        s00_axi_awready => master_test_0_M00_AXI_AWREADY,
        s00_axi_awvalid => master_test_0_M00_AXI_AWVALID,
        s00_axi_bready => master_test_0_M00_AXI_BREADY,
        s00_axi_bresp(1 downto 0) => master_test_0_M00_AXI_BRESP(1 downto 0),
        s00_axi_bvalid => master_test_0_M00_AXI_BVALID,
        s00_axi_rdata(31 downto 0) => master_test_0_M00_AXI_RDATA(31 downto 0),
        s00_axi_rready => master_test_0_M00_AXI_RREADY,
        s00_axi_rresp(1 downto 0) => master_test_0_M00_AXI_RRESP(1 downto 0),
        s00_axi_rvalid => master_test_0_M00_AXI_RVALID,
        s00_axi_wdata(31 downto 0) => master_test_0_M00_AXI_WDATA(31 downto 0),
        s00_axi_wready => master_test_0_M00_AXI_WREADY,
        s00_axi_wstrb(3 downto 0) => master_test_0_M00_AXI_WSTRB(3 downto 0),
        s00_axi_wvalid => master_test_0_M00_AXI_WVALID
    );

end architecture rtl;