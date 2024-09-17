library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity design_top is
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
        
        clk : in STD_LOGIC;
        nrst : in STD_LOGIC
    );
end entity design_top;

architecture rtl of design_top is
    constant AXI_SLAVE_ADDR_WITH : natural := 4;
    
    component axi_lite is
        port (
            
            S_AXI_ACLK    : in std_logic;
            S_AXI_ARESETN    : in std_logic;
            S_AXI_AWADDR    : in std_logic_vector(AXI_SLAVE_ADDR_WITH - 1 downto 0);
            S_AXI_AWPROT    : in std_logic_vector(2 downto 0);
            S_AXI_AWVALID    : in std_logic;
            S_AXI_AWREADY    : out std_logic;
            S_AXI_WDATA    : in std_logic_vector(31 downto 0);
            S_AXI_WSTRB    : in std_logic_vector(3 downto 0);
            S_AXI_WVALID    : in std_logic;
            S_AXI_WREADY    : out std_logic;
            S_AXI_BRESP    : out std_logic_vector(1 downto 0);
            S_AXI_BVALID    : out std_logic;
            S_AXI_BREADY    : in std_logic;
            S_AXI_ARADDR    : in std_logic_vector(AXI_SLAVE_ADDR_WITH - 1 downto 0);
            S_AXI_ARPROT    : in std_logic_vector(2 downto 0);
            S_AXI_ARVALID    : in std_logic;
            S_AXI_ARREADY    : out std_logic;
            S_AXI_RDATA    : out std_logic_vector(31 downto 0);
            S_AXI_RRESP    : out std_logic_vector(1 downto 0);
            S_AXI_RVALID    : out std_logic;
            S_AXI_RREADY    : in std_logic
        );
    end component axi_lite;

    component master_axi_base_top is
        port (
              ------------- debug from tb ----------
            test_wdata  : in std_logic_vector(31 downto 0);
            test_awaddr : in std_logic_vector(31 downto 0);
            test_araddr : in std_logic_vector(31 downto 0);
            test_rdata  : out std_logic_vector(31 downto 0);
            m00_axi_init_axi_txn : in STD_LOGIC;
            m00_axi_init_axi_rxn : in STD_LOGIC;
            m00_axi_txn_ready    : out std_logic;
            m00_axi_rxn_ready    : out std_logic;
              --------------------------------------

            
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
    port map (
        
        ------------- debug from tb ----------
        test_wdata  => test_wdata,
        test_awaddr => test_awaddr,
        test_araddr => test_araddr,
        test_rdata  => test_rdata,
        m00_axi_init_axi_txn => m00_axi_init_axi_txn,
        m00_axi_init_axi_rxn => m00_axi_init_axi_rxn,
        m00_axi_rxn_ready => m00_axi_rxn_ready,
        m00_axi_txn_ready => m00_axi_txn_ready,
        -------------------------------------
        
        m00_axi_aclk => clk,
        m00_axi_araddr => master_test_0_M00_AXI_ARADDR(31 downto 0),
        m00_axi_aresetn => nrst,
        m00_axi_arprot => master_test_0_M00_AXI_ARPROT(2 downto 0),
        m00_axi_arready => master_test_0_M00_AXI_ARREADY,
        m00_axi_arvalid => master_test_0_M00_AXI_ARVALID,
        m00_axi_awaddr => master_test_0_M00_AXI_AWADDR(31 downto 0),
        m00_axi_awprot => master_test_0_M00_AXI_AWPROT(2 downto 0),
        m00_axi_awready => master_test_0_M00_AXI_AWREADY,
        m00_axi_awvalid => master_test_0_M00_AXI_AWVALID,
        m00_axi_bready => master_test_0_M00_AXI_BREADY,
        m00_axi_bresp => master_test_0_M00_AXI_BRESP(1 downto 0),
        m00_axi_bvalid => master_test_0_M00_AXI_BVALID,
        m00_axi_rdata => master_test_0_M00_AXI_RDATA(31 downto 0),
        m00_axi_rready => master_test_0_M00_AXI_RREADY,
        m00_axi_rresp => master_test_0_M00_AXI_RRESP(1 downto 0),
        m00_axi_rvalid => master_test_0_M00_AXI_RVALID,
        m00_axi_wdata => master_test_0_M00_AXI_WDATA(31 downto 0),
        m00_axi_wready => master_test_0_M00_AXI_WREADY,
        m00_axi_wstrb => master_test_0_M00_AXI_WSTRB(3 downto 0),
        m00_axi_wvalid => master_test_0_M00_AXI_WVALID
    );
    
    slave_lite_tb_0: component axi_lite
    port map (
        S_AXI_ACLK => clk,
        S_AXI_ARADDR => master_test_0_M00_AXI_ARADDR(AXI_SLAVE_ADDR_WITH - 1 downto 0),
        S_AXI_ARESETN => nrst,
        S_AXI_ARPROT => master_test_0_M00_AXI_ARPROT(2 downto 0),
        S_AXI_ARREADY => master_test_0_M00_AXI_ARREADY,
        S_AXI_ARVALID => master_test_0_M00_AXI_ARVALID,
        S_AXI_AWADDR => master_test_0_M00_AXI_AWADDR(AXI_SLAVE_ADDR_WITH - 1 downto 0),
        S_AXI_AWPROT => master_test_0_M00_AXI_AWPROT(2 downto 0),
        S_AXI_AWREADY => master_test_0_M00_AXI_AWREADY,
        S_AXI_AWVALID => master_test_0_M00_AXI_AWVALID,
        S_AXI_BREADY => master_test_0_M00_AXI_BREADY,
        S_AXI_BRESP => master_test_0_M00_AXI_BRESP(1 downto 0),
        S_AXI_BVALID => master_test_0_M00_AXI_BVALID,
        S_AXI_RDATA => master_test_0_M00_AXI_RDATA(31 downto 0),
        S_AXI_RREADY => master_test_0_M00_AXI_RREADY,
        S_AXI_RRESP => master_test_0_M00_AXI_RRESP(1 downto 0),
        S_AXI_RVALID => master_test_0_M00_AXI_RVALID,
        S_AXI_WDATA => master_test_0_M00_AXI_WDATA(31 downto 0),
        S_AXI_WREADY => master_test_0_M00_AXI_WREADY,
        S_AXI_WSTRB => master_test_0_M00_AXI_WSTRB(3 downto 0),
        S_AXI_WVALID => master_test_0_M00_AXI_WVALID
    );

end architecture rtl;