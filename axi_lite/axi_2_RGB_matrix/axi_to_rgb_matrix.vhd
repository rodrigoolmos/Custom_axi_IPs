library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_to_rgb_matrix is
    generic (
        CLK_DIV     : natural := 20;
        DEBUG       : std_logic := '0'
    );
    port (
        ------------------------------------------------
        RGB0    : out   std_logic_vector(2 downto 0);
        RGB1    : out   std_logic_vector(2 downto 0);
        ADDR    : out   std_logic_vector(4 downto 0);
        LAT     : out   std_logic;
        CLOCK_O : out   std_logic;
        OE      : out   std_logic;
        ------------------------------------------------
        S_AXI_ACLK    : in std_logic;
        S_AXI_ARESETN    : in std_logic;
        S_AXI_AWADDR    : in std_logic_vector(12 downto 0);
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
        S_AXI_ARADDR    : in std_logic_vector(12 downto 0);
        S_AXI_ARPROT    : in std_logic_vector(2 downto 0);
        S_AXI_ARVALID    : in std_logic;
        S_AXI_ARREADY    : out std_logic;
        S_AXI_RDATA    : out std_logic_vector(31 downto 0);
        S_AXI_RRESP    : out std_logic_vector(1 downto 0);
        S_AXI_RVALID    : out std_logic;
        S_AXI_RREADY    : in std_logic
    );
end axi_to_rgb_matrix;

architecture arch_imp of axi_to_rgb_matrix is

    signal ADDR_A_signal : STD_LOGIC_VECTOR(10 downto 0);
    signal DOUT_A_signal : STD_LOGIC_VECTOR(7 downto 0);


begin

    inst_RGB_matrix : entity work.RGB_matrix
    generic map (
        MAX_CNT => CLK_DIV,   
        DEBUG   => DEBUG   
    )
    port map (
        CLK     => S_AXI_ACLK,     
        NRST    => S_AXI_ARESETN,  
        DATA    => DOUT_A_signal,    
        N_ROW   => ADDR_A_signal(10 downto 6),   
        N_COL   => ADDR_A_signal(5 downto 0),   
        RGB0    => RGB0,    
        RGB1    => RGB1,    
        ADDR    => ADDR,    
        LAT     => LAT,     
        CLOCK_O => CLOCK_O, 
        OE      => OE       
    );

-- Instanciación del módulo axi_lite_to_bram
inst_axi_lite_to_bram : entity work.axi_lite_to_bram
    generic map (
        MEM_DATA_WIDTH => 8,  -- Ancho del bus de datos
        MEM_ADDR_WIDTH => 11     -- Ancho del bus de direcciones
    )
    port map (
        WE_A           => '0',
        DIN_A          => x"00",
        ADDR_A         => ADDR_A_signal,
        DOUT_A         => DOUT_A_signal,
        S_AXI_ACLK     => S_AXI_ACLK,
        S_AXI_ARESETN  => S_AXI_ARESETN,
        S_AXI_AWADDR   => S_AXI_AWADDR,
        S_AXI_AWPROT   => S_AXI_AWPROT,
        S_AXI_AWVALID  => S_AXI_AWVALID,
        S_AXI_AWREADY  => S_AXI_AWREADY,
        S_AXI_WDATA     => S_AXI_WDATA,
        S_AXI_WSTRB     => S_AXI_WSTRB,
        S_AXI_WVALID    => S_AXI_WVALID,
        S_AXI_WREADY    => S_AXI_WREADY,
        S_AXI_BRESP     => S_AXI_BRESP,
        S_AXI_BVALID    => S_AXI_BVALID,
        S_AXI_BREADY    => S_AXI_BREADY,
        S_AXI_ARADDR    => S_AXI_ARADDR,
        S_AXI_ARPROT    => S_AXI_ARPROT,
        S_AXI_ARVALID   => S_AXI_ARVALID,
        S_AXI_ARREADY   => S_AXI_ARREADY,
        S_AXI_RDATA     => S_AXI_RDATA,
        S_AXI_RRESP     => S_AXI_RRESP,
        S_AXI_RVALID    => S_AXI_RVALID,
        S_AXI_RREADY    => S_AXI_RREADY
    );


end arch_imp;