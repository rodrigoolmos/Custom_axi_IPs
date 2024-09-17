library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity top_tb is
end entity top_tb;

architecture rtl of top_tb is
    
	function clogb2 (bit_depth : integer) return integer is            
        variable depth  : integer := bit_depth;                               
        variable count  : integer := 1;                                       
    begin                                                                   
         for clogb2 in 1 to bit_depth loop  -- Works for up to 32 bit integers
         if (bit_depth <= 2) then                                           
           count := 1;                                                      
         else                                                               
           if(depth <= 1) then                                              
               count := count;                                                
             else                                                             
               depth := depth / 2;                                            
             count := count + 1;                                            
             end if;                                                          
           end if;                                                            
      end loop;                                                             
      return(count);        	                                              
    end;   

    constant period_time : time := 83333 ps; -- 12MHz
    constant AXI_BURST_LEN      : integer := 256;
    constant RAM_DEPTH          : integer := 1024;
    constant DATA_WIDTH         : integer := 4;


    signal   finished  : std_logic := '0';
    
    signal CLK : std_logic := '0';
    signal NRST : std_logic := '0';
    signal INIT_AXI_TXN : std_logic := '0';
    signal INIT_AXI_RXN : std_logic := '0';
    signal BASE_AWADDR : std_logic_vector ( 31 downto 0 );
    signal BASE_ARADDR : std_logic_vector ( 31 downto 0 );
    signal N_BURSTs_RW : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal C_M_AXI_BURST_LEN_PORT : STD_LOGIC_VECTOR ( 7 downto 0 );
    signal M_AXI_WDATA_TB : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal M_AXI_RDATA_TB : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal M_AXI_WSTRB_TB : STD_LOGIC_VECTOR ( 3 downto 0 );
    signal WRITE_VALID : STD_LOGIC;
    signal READ_VALID : STD_LOGIC;
    signal SYSTEM_IDLE : STD_LOGIC;

    
    type RAM_TYPE is array (0 to RAM_DEPTH - 1) of std_logic_vector(31 downto 0); -- TODO PARAMETRIZAR ESTO
    signal ram_write : RAM_TYPE;
    signal ram_read : RAM_TYPE;

    
    signal i : integer := 0;
    
    component design_1_wrapper is
        port(
            INIT_AXI_TXN : in STD_LOGIC;
            NRST : in STD_LOGIC;
            CLK : in STD_LOGIC;
            INIT_AXI_RXN : in STD_LOGIC;
            BASE_AWADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
            BASE_ARADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
            N_BURSTs_RW : in STD_LOGIC_VECTOR ( 31 downto 0 );
            M_AXI_WDATA_TB : in STD_LOGIC_VECTOR ( 31 downto 0 );
            M_AXI_RDATA_TB : out STD_LOGIC_VECTOR ( 31 downto 0 );
            WRITE_VALID : out STD_LOGIC;
            READ_VALID : out STD_LOGIC;
            M_AXI_WSTRB_TB : in STD_LOGIC_VECTOR ( 3 downto 0 );
            SYSTEM_IDLE : out STD_LOGIC
        );
    end component design_1_wrapper;
    
    procedure fill_ram(
        constant RAM_DEPTH0 : integer;
        signal ram : out RAM_TYPE) is
    begin
        for index in 1 to RAM_DEPTH0 loop
            ram(index - 1) <= std_logic_vector(to_unsigned(index, 32));
        end loop;
    end procedure;

    procedure test_integrity(
        constant N_DATA : integer;
        signal ram_w : in RAM_TYPE;
        signal ram_r : in RAM_TYPE) is
    begin
        for index in 0 to N_DATA - 1 loop
            assert ram_w(index) = ram_r(index)
                report "ERROR READ WRITE NOT INTEGRITY"
                severity FAILURE;
        end loop;
    end procedure;

    procedure send_data(
        constant wr_addr        : integer;
        constant data_size      : integer;
        signal data             : in RAM_TYPE;
        constant ram_offset     : integer;
        constant burst_size     : integer;
        signal N_BURSTs_RW0     : out STD_LOGIC_VECTOR ( 31 downto 0 );
        signal BASE_AWADDR0     : out STD_LOGIC_VECTOR ( 31 downto 0 );
        signal M_AXI_WSTRB_TB0  : out STD_LOGIC_VECTOR ( 3 downto 0 );
        signal INIT_AXI_TXN0    : out STD_LOGIC;
        signal WRITE_VALID0     : in STD_LOGIC;
        signal SYSTEM_IDLE0     : in STD_LOGIC;
        signal M_AXI_WDATA_TB0  : out STD_LOGIC_VECTOR ( 31 downto 0 )
        ) is
    variable n_bursts_aux : integer; 
    variable i : integer;     
    variable rest : unsigned(31 downto 0);     

    begin
        M_AXI_WSTRB_TB0 <= (others => '1');
        rest := to_unsigned(data_size, 32) mod to_unsigned(burst_size, 32);

        if rest > 0 then
            n_bursts_aux := data_size / burst_size + clogb2(burst_size) + 2;
        else
            n_bursts_aux := data_size / burst_size + clogb2(burst_size) + 1;
        end if;
        N_BURSTs_RW0 <= std_logic_vector(to_unsigned(n_bursts_aux, 32));
        BASE_AWADDR0 <= std_logic_vector(to_unsigned(wr_addr, 32));
        INIT_AXI_TXN0 <= '1';
        wait until rising_edge(CLK);
        INIT_AXI_TXN0 <= '0';
        i := 0;
        M_AXI_WDATA_TB0 <= data(i + ram_offset);
        loop
            wait until WRITE_VALID0 = '1' and rising_edge(CLK);
            i := i + 1;
            M_AXI_WDATA_TB0 <= data(i + ram_offset);
            if i = data_size - 1 then
                wait until WRITE_VALID0 = '1' and rising_edge(CLK);
                M_AXI_WSTRB_TB0 <= (others => '0');
                exit;
            end if;
        end loop;
        wait until SYSTEM_IDLE0 = '1';

    end procedure;

    procedure read_data(
        constant rd_addr        : integer;
        constant data_size      : integer;
        signal data             : out RAM_TYPE;
        constant ram_offset : integer;
        constant burst_size     : integer;
        signal N_BURSTs_RW0     : out STD_LOGIC_VECTOR ( 31 downto 0 );
        signal BASE_ARADDR0     : out STD_LOGIC_VECTOR ( 31 downto 0 );
        signal INIT_AXI_RXN0    : out STD_LOGIC;
        signal READ_VALID0      : in STD_LOGIC;
        signal M_AXI_RDATA_TB0  : in STD_LOGIC_VECTOR ( 31 downto 0 );
        signal SYSTEM_IDLE0     : in STD_LOGIC
        ) is
    variable n_bursts_aux : integer; 
    variable i : integer;
    variable rest : unsigned(31 downto 0);     
    begin
        rest := to_unsigned(data_size, 32) mod to_unsigned(burst_size, 32);

        if rest > 0 then
            n_bursts_aux := data_size / burst_size + clogb2(burst_size) + 2;
        else
            n_bursts_aux := data_size / burst_size + clogb2(burst_size) + 1;
        end if;
        N_BURSTs_RW0 <= std_logic_vector(to_unsigned(n_bursts_aux, 32));
        BASE_ARADDR0 <= std_logic_vector(to_unsigned(rd_addr, 32));
        INIT_AXI_RXN0 <= '1';
        wait until rising_edge(CLK);
        INIT_AXI_RXN0 <= '0';
        i := 0;
        loop
            if i < data_size then
                wait until READ_VALID0 = '1' and rising_edge(CLK);
                data(i + ram_offset) <= M_AXI_RDATA_TB0;
                i := i + 1;
            else
                wait until SYSTEM_IDLE0 = '1';
                exit;
            end if;
        end loop; 

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
        C_M_AXI_BURST_LEN_PORT <= "10000000";
        NRST <= '0';
        INIT_AXI_TXN <= '0';
        INIT_AXI_RXN <= '0';
        BASE_AWADDR <= x"00000000";
        BASE_ARADDR <= x"00000000";
        M_AXI_WSTRB_TB <= "0000";
        wait for 1 ps;
        wait until rising_edge(CLK);
        NRST <= '1';
        wait until rising_edge(CLK);
        wait for 5 us;
        wait until rising_edge(CLK);
        fill_ram(RAM_DEPTH, ram_write);
        
        -- TX
        send_data(16#0000# + 257 * DATA_WIDTH, 257, ram_write, 257, 
                    AXI_BURST_LEN, N_BURSTs_RW, BASE_AWADDR, M_AXI_WSTRB_TB,
                    INIT_AXI_TXN, WRITE_VALID, SYSTEM_IDLE, M_AXI_WDATA_TB);
        send_data(16#0000# + 0 * DATA_WIDTH, 257, ram_write, 0, AXI_BURST_LEN, 
                    N_BURSTs_RW, BASE_AWADDR, M_AXI_WSTRB_TB,
                    INIT_AXI_TXN, WRITE_VALID, SYSTEM_IDLE, M_AXI_WDATA_TB);
        send_data(16#0000# + 514 * DATA_WIDTH, 37, ram_write, 514, 
                    AXI_BURST_LEN, N_BURSTs_RW, BASE_AWADDR, M_AXI_WSTRB_TB,
                    INIT_AXI_TXN, WRITE_VALID, SYSTEM_IDLE, M_AXI_WDATA_TB);
        send_data(16#0000# + 551 * DATA_WIDTH, 473, ram_write, 551, 
                    AXI_BURST_LEN, N_BURSTs_RW, BASE_AWADDR, M_AXI_WSTRB_TB,
                    INIT_AXI_TXN, WRITE_VALID, SYSTEM_IDLE, M_AXI_WDATA_TB);
        -- RX
        read_data(16#0000#, 1024, ram_read, 0, AXI_BURST_LEN, N_BURSTs_RW, BASE_ARADDR, 
                    INIT_AXI_RXN, READ_VALID, M_AXI_RDATA_TB, SYSTEM_IDLE);
        test_integrity(1024, ram_write, ram_read);

        -- TX
        send_data(16#2000# + 518 * DATA_WIDTH, 506, ram_write, 518, 
                    AXI_BURST_LEN, N_BURSTs_RW, BASE_AWADDR, M_AXI_WSTRB_TB,
                    INIT_AXI_TXN, WRITE_VALID, SYSTEM_IDLE, M_AXI_WDATA_TB);
        send_data(16#2000# + 0 * DATA_WIDTH, 518, ram_write, 0, 
                    AXI_BURST_LEN, N_BURSTs_RW, BASE_AWADDR, M_AXI_WSTRB_TB,
                    INIT_AXI_TXN, WRITE_VALID, SYSTEM_IDLE, M_AXI_WDATA_TB);
        -- RX
        read_data(16#2000#, 1024, ram_read, 0, AXI_BURST_LEN, N_BURSTs_RW, BASE_ARADDR, 
                    INIT_AXI_RXN, READ_VALID, M_AXI_RDATA_TB, SYSTEM_IDLE);
        test_integrity(1024, ram_write, ram_read);

        -- TX
        send_data(16#4000#, 748, ram_write, 0, AXI_BURST_LEN, N_BURSTs_RW, BASE_AWADDR, M_AXI_WSTRB_TB,
                    INIT_AXI_TXN, WRITE_VALID, SYSTEM_IDLE, M_AXI_WDATA_TB);
        -- RX
        read_data(16#4000#, 748, ram_read, 0, AXI_BURST_LEN, N_BURSTs_RW, BASE_ARADDR, 
                    INIT_AXI_RXN, READ_VALID, M_AXI_RDATA_TB, SYSTEM_IDLE);
        test_integrity(748, ram_write, ram_read);

        -- TX
        send_data(16#6000#, 900, ram_write, 0, AXI_BURST_LEN, N_BURSTs_RW, BASE_AWADDR, M_AXI_WSTRB_TB,
                    INIT_AXI_TXN, WRITE_VALID, SYSTEM_IDLE, M_AXI_WDATA_TB);
        -- RX
        read_data(16#6000# + 300 * DATA_WIDTH, 300, ram_read, 300, 
                    AXI_BURST_LEN, N_BURSTs_RW, BASE_ARADDR, 
                    INIT_AXI_RXN, READ_VALID, M_AXI_RDATA_TB, SYSTEM_IDLE);
        read_data(16#6000# + 0 * DATA_WIDTH, 300, ram_read, 0, 
                    AXI_BURST_LEN, N_BURSTs_RW, BASE_ARADDR, 
                    INIT_AXI_RXN, READ_VALID, M_AXI_RDATA_TB, SYSTEM_IDLE);
        read_data(16#6000# + 600 * DATA_WIDTH, 300, ram_read, 600, 
                    AXI_BURST_LEN, N_BURSTs_RW, BASE_ARADDR, 
                    INIT_AXI_RXN, READ_VALID, M_AXI_RDATA_TB, SYSTEM_IDLE);
        test_integrity(900, ram_write, ram_read);

        wait for 5 us;
        finished <= '1';
        wait;
    end process;

    u1: design_1_wrapper
    port map
    (
        CLK => CLK,
        NRST => NRST,
        INIT_AXI_TXN => INIT_AXI_TXN,
        INIT_AXI_RXN => INIT_AXI_RXN,
        BASE_AWADDR => BASE_AWADDR,
        BASE_ARADDR => BASE_ARADDR,
        N_BURSTs_RW => N_BURSTs_RW,
        M_AXI_WDATA_TB => M_AXI_WDATA_TB,
        M_AXI_RDATA_TB => M_AXI_RDATA_TB,
        WRITE_VALID => WRITE_VALID,
        READ_VALID  => READ_VALID,
        M_AXI_WSTRB_TB => M_AXI_WSTRB_TB,
        SYSTEM_IDLE =>  SYSTEM_IDLE
    );

end architecture rtl;

