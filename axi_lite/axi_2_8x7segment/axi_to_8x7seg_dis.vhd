library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_to_8x7seg_dis is
    generic(
        multiplex_clk_cicles : natural := 125000
    );
    port (
        mutiplex            : out std_logic_vector(7 downto 0);
        display             : out std_logic_vector(7 downto 0);
        -- User ports ends
        -- Do not modify the ports beyond this line

        S_AXI_ACLK    : in std_logic;
        S_AXI_ARESETN    : in std_logic;
        S_AXI_AWADDR    : in std_logic_vector(31 downto 0);
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
        S_AXI_ARADDR    : in std_logic_vector(31 downto 0);
        S_AXI_ARPROT    : in std_logic_vector(2 downto 0);
        S_AXI_ARVALID    : in std_logic;
        S_AXI_ARREADY    : out std_logic;
        S_AXI_RDATA    : out std_logic_vector(31 downto 0);
        S_AXI_RRESP    : out std_logic_vector(1 downto 0);
        S_AXI_RVALID    : out std_logic;
        S_AXI_RREADY    : in std_logic
    );
end axi_to_8x7seg_dis;

architecture arch_imp of axi_to_8x7seg_dis is

    -- AXI4LITE signals
    signal axi_awaddr    : std_logic_vector(31 downto 0);
    signal axi_awready    : std_logic;
    signal axi_wready    : std_logic;
    signal axi_bresp    : std_logic_vector(1 downto 0);
    signal axi_bvalid    : std_logic;
    signal axi_arready    : std_logic;
    signal axi_rresp    : std_logic_vector(1 downto 0);
    signal axi_rvalid    : std_logic;

    ---- Number of Slave Registers 4
    signal slv_reg_rden    : std_logic;
    signal slv_reg_wren    : std_logic;
    signal aw_en    : std_logic;

    ------------------------------------------------
    ---- Signals for user logic register space example
    --------------------------------------------------

    signal counter : unsigned(31 downto 0) := (others => '0');
    signal mutiplex_reg : std_logic_vector(7 downto 0);
    signal data_reg : std_logic_vector(63 downto 0);
    signal mode_reg : std_logic_vector(63 downto 0);
    signal aux_disp_custom : std_logic_vector(7 downto 0);
    signal aux_disp_decode : std_logic_vector(7 downto 0);

begin
    -- I/O Connections assignments

    S_AXI_AWREADY    <= axi_awready;
    S_AXI_WREADY    <= axi_wready;
    S_AXI_BRESP    <= axi_bresp;
    S_AXI_BVALID    <= axi_bvalid;
    S_AXI_ARREADY    <= axi_arready;
    S_AXI_RDATA    <= (others => '0');
    S_AXI_RRESP    <= axi_rresp;
    S_AXI_RVALID    <= axi_rvalid;
    -- Implement axi_awready generation
    -- axi_awready is asserted for one S_AXI_ACLK clock cycle when both
    -- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
    -- de-asserted when reset is low.

    process (S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then
            if S_AXI_ARESETN = '0' then
                axi_awready <= '0';
                aw_en <= '1';
            else
                if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' and aw_en = '1') then
            -- slave is ready to accept write address when
            -- there is a valid write address and write data
            -- on the write address and data bus. This design
            -- expects no outstanding transactions.
                    axi_awready <= '1';
                    aw_en <= '0';
                elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then
                    aw_en <= '1';
                    axi_awready <= '0';
                else
                    axi_awready <= '0';
                end if;
            end if;
        end if;
    end process;

    -- Implement axi_awaddr latching
    -- This process is used to latch the address when both
    -- S_AXI_AWVALID and S_AXI_WVALID are valid.

    process (S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then
            if S_AXI_ARESETN = '0' then
                axi_awaddr <= (others => '0');
            else
                if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' and aw_en = '1') then
            -- Write Address latching
                    axi_awaddr <= S_AXI_AWADDR;
                end if;
            end if;
        end if;
    end process;

    -- Implement axi_wready generation
    -- axi_wready is asserted for one S_AXI_ACLK clock cycle when both
    -- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is
    -- de-asserted when reset is low.

    process (S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then
            if S_AXI_ARESETN = '0' then
                axi_wready <= '0';
            else
                if (axi_wready = '0' and S_AXI_WVALID = '1' and S_AXI_AWVALID = '1' and aw_en = '1') then
              -- slave is ready to accept write data when
              -- there is a valid write address and write data
              -- on the write address and data bus. This design
              -- expects no outstanding transactions.
                    axi_wready <= '1';
                else
                    axi_wready <= '0';
                end if;
            end if;
        end if;
    end process;

    slv_reg_wren <= axi_wready and S_AXI_WVALID and axi_awready and S_AXI_AWVALID ;

    

    -- Implement write response logic generation
    -- The write response and response valid signals are asserted by the slave
    -- when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.
    -- This marks the acceptance of address and indicates the status of
    -- write transaction.

    process (S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then
            if S_AXI_ARESETN = '0' then
                axi_bvalid  <= '0';
                axi_bresp   <= "00"; --need to work more on the responses
            else
                if (axi_awready = '1' and S_AXI_AWVALID = '1' and axi_wready = '1' and S_AXI_WVALID = '1' and axi_bvalid = '0'  ) then
                    axi_bvalid <= '1';
                    axi_bresp  <= "00";
                elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then   --check if bready is asserted while bvalid is high)
                    axi_bvalid <= '0';                                 -- (there is a possibility that bready is always asserted high)
                end if;
            end if;
        end if;
    end process;

    -- Implement axi_arready generation
    -- axi_arready is asserted for one S_AXI_ACLK clock cycle when
    -- S_AXI_ARVALID is asserted. axi_awready is
    -- de-asserted when reset (active low) is asserted.
    -- The read address is also latched when S_AXI_ARVALID is
    -- asserted. axi_araddr is reset to zero on reset assertion.

    process (S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then
            if S_AXI_ARESETN = '0' then
                axi_arready <= '0';
            else
                if (axi_arready = '0' and S_AXI_ARVALID = '1') then
            -- indicates that the slave has acceped the valid read address
                    axi_arready <= '1';
            -- Read Address latching
                else
                    axi_arready <= '0';
                end if;
            end if;
        end if;
    end process;

    -- Implement axi_arvalid generation
    -- axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both
    -- S_AXI_ARVALID and axi_arready are asserted. The slave registers
    -- data are available on the axi_rdata bus at this instance. The
    -- assertion of axi_rvalid marks the validity of read data on the
    -- bus and axi_rresp indicates the status of read transaction.axi_rvalid
    -- is deasserted on reset (active low). axi_rresp and axi_rdata are
    -- cleared to zero on reset (active low).
    process (S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then
            if S_AXI_ARESETN = '0' then
                axi_rvalid <= '0';
                axi_rresp  <= "00";
            else
                if (axi_arready = '1' and S_AXI_ARVALID = '1' and axi_rvalid = '0') then
            -- Valid read data is available at the read data bus
                    axi_rvalid <= '1';
                    axi_rresp  <= "00"; -- 'OKAY' response
                elsif (axi_rvalid = '1' and S_AXI_RREADY = '1') then
            -- Read data is accepted by the master
                    axi_rvalid <= '0';
                end if;
            end if;
        end if;
    end process;

    -- Implement memory mapped register select and read logic generation
    -- Slave register read enable is asserted when valid address is available
    -- and the slave is ready to accept the read address.
    slv_reg_rden <= axi_arready and S_AXI_ARVALID and (not axi_rvalid) ;


    -- Add user logic here
    mux: process(S_AXI_ACLK, S_AXI_ARESETN)
    begin
        if S_AXI_ARESETN = '0' then
            counter <= (others => '0');
            mutiplex_reg <= "11111110";
        elsif rising_edge(S_AXI_ACLK) then
            if counter < multiplex_clk_cicles - 1 then
                counter <= counter + 1;
            else
                mutiplex_reg <= mutiplex_reg(6 downto 0)&mutiplex_reg(7);
                counter <= (others => '0');
            end if;
        end if;
    end process mux;

    process(S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then
            if S_AXI_ARESETN = '0' then
                data_reg <= x"0123456780ABCDEF";
                mode_reg <= x"0000000000000000";
            else
                if slv_reg_wren = '1' and axi_awaddr(3 downto 2) = "00" then
                    data_reg(31 downto 0) <= S_AXI_WDATA;
                elsif slv_reg_wren = '1' and axi_awaddr(3 downto 2) = "01" then
                    mode_reg(31 downto 0) <= S_AXI_WDATA;
                elsif slv_reg_wren = '1' and axi_awaddr(3 downto 2) = "10" then
                    data_reg(63 downto 32) <= S_AXI_WDATA;
                elsif slv_reg_wren = '1' and axi_awaddr(3 downto 2) = "11" then
                    mode_reg(63 downto 32) <= S_AXI_WDATA;
                else
                    data_reg <= data_reg;
                    mode_reg <= mode_reg;
                end if;
            end if ;
        end if;
    end process;
    -- User logic ends

    aux_disp_custom <=
    data_reg(7 downto 0) when mutiplex_reg =   "11111110" else
    data_reg(15 downto 8) when mutiplex_reg =  "11111101" else
    data_reg(23 downto 16) when mutiplex_reg = "11111011" else
    data_reg(31 downto 24) when mutiplex_reg = "11110111" else
    data_reg(39 downto 32) when mutiplex_reg = "11101111" else
    data_reg(47 downto 40) when mutiplex_reg = "11011111" else
    data_reg(55 downto 48) when mutiplex_reg = "10111111" else
    data_reg(63 downto 56) when mutiplex_reg = "01111111" else
                "00000000";
    
    aux_disp_decode <=
                "11000000" when aux_disp_custom = x"00" else
                "11111001" when aux_disp_custom = x"01" else
                "10100100" when aux_disp_custom = x"02" else
                "10110000" when aux_disp_custom = x"03" else
                "10011001" when aux_disp_custom = x"04" else
                "10010010" when aux_disp_custom = x"05" else
                "10000010" when aux_disp_custom = x"06" else
                "11111000" when aux_disp_custom = x"07" else
                "10000000" when aux_disp_custom = x"08" else
                "10011000" when aux_disp_custom = x"09" else
                "10001000" when aux_disp_custom = x"0A" else
                "10000011" when aux_disp_custom = x"0B" else
                "11000110" when aux_disp_custom = x"0C" else
                "10100001" when aux_disp_custom = x"0D" else
                "10000110" when aux_disp_custom = x"0E" else
                "10001110" when aux_disp_custom = x"0F" else
                "00000000";
    
    display <= aux_disp_custom when
                (mutiplex_reg = "11111110" and mode_reg(0)  = '1') or
                (mutiplex_reg = "11111101" and mode_reg(8)  = '1') or
                (mutiplex_reg = "11111011" and mode_reg(16) = '1') or
                (mutiplex_reg = "11110111" and mode_reg(24) = '1') or
                (mutiplex_reg = "11101111" and mode_reg(32) = '1') or
                (mutiplex_reg = "11011111" and mode_reg(40) = '1') or
                (mutiplex_reg = "10111111" and mode_reg(48) = '1') or
                (mutiplex_reg = "01111111" and mode_reg(56) = '1')
            else
                aux_disp_decode;
    
    mutiplex <= mutiplex_reg;
end arch_imp;