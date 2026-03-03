-------------------------------------------------------------------------
-- Shawn Robinson 
-------------------------------------------------------------------------
-- tb_second_datapath.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: Testbench for second_datapath with load/store instructions
--
-- NOTES: 
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_second_datapath is
  generic(gCLK_HPER : time := 50 ns);
end tb_second_datapath;

architecture behavioral of tb_second_datapath is
  
  constant cCLK_PER : time := gCLK_HPER * 2;

  component second_datapath
    port(
      clk_dp              : in std_logic; 
      reset_dp            : in std_logic; 
      write_enable_dp     : in std_logic; 
      ALUsrc              : in std_logic; 
      add_sub_select_dp   : in std_logic; 
      MemWrite            : in std_logic; 
      MemToReg            : in std_logic; 
      rd_address_dp       : in std_logic_vector(4 downto 0); 
      rs1_address_dp      : in std_logic_vector(4 downto 0); 
      rs2_address_dp      : in std_logic_vector(4 downto 0); 
      rs1_read_dp         : out std_logic_vector(31 downto 0); 
      rs2_read_dp         : out std_logic_vector(31 downto 0);
      immediate_value_dp  : in std_logic_vector(11 downto 0)
    );  
  end component;

  -- Signals
  signal s_clk_dp           : std_logic := '0';
  signal s_reset_dp         : std_logic := '0';
  signal s_write_enable     : std_logic := '0';
  signal s_ALUsrc           : std_logic := '0'; 
  signal s_add_sub_select   : std_logic := '0';
  signal s_MemWrite         : std_logic := '0';
  signal s_MemToReg         : std_logic := '0';
  signal s_rd_address       : std_logic_vector(4 downto 0) := (others => '0');
  signal s_rs1_address      : std_logic_vector(4 downto 0) := (others => '0');
  signal s_rs2_address      : std_logic_vector(4 downto 0) := (others => '0');
  signal s_immediate_value  : std_logic_vector(11 downto 0) := (others => '0');
  signal s_rs1_out          : std_logic_vector(31 downto 0);  
  signal s_rs2_out          : std_logic_vector(31 downto 0);   

begin

  DUT: second_datapath 
    port map(
      clk_dp            => s_clk_dp, 
      reset_dp          => s_reset_dp,
      write_enable_dp   => s_write_enable,
      ALUsrc            => s_ALUsrc,
      add_sub_select_dp => s_add_sub_select,
      MemWrite          => s_MemWrite,
      MemToReg          => s_MemToReg,
      rd_address_dp     => s_rd_address,
      rs1_address_dp    => s_rs1_address,
      rs2_address_dp    => s_rs2_address,
      rs1_read_dp       => s_rs1_out,
      rs2_read_dp       => s_rs2_out,
      immediate_value_dp => s_immediate_value
    );  

  -- Clock process
  P_CLK: process
  begin
    s_clk_dp <= '0';
    wait for gCLK_HPER;
    s_clk_dp <= '1';
    wait for gCLK_HPER;
  end process;
  

  P_TB: process
  begin

    -------------------------------------------------------
    -- RESET: clear all registers for 2 cycles
    -------------------------------------------------------
    s_reset_dp      <= '1';
    s_write_enable  <= '0';
    s_MemWrite      <= '0';
    s_MemToReg      <= '0';
    s_ALUsrc        <= '0';
    s_add_sub_select <= '0';
    wait for cCLK_PER * 2;
    s_reset_dp      <= '0';
    wait for cCLK_PER;

    -------------------------------------------------------
    -- NOTE ON BASE ADDRESSES:
    -- The lab states x25/x26/x27 initially hold 0x10010000.
    -- A 12-bit immediate cannot load this value directly.
    -- The addi instructions ADD to the existing register:
    --   addi x25, x25, 0   -> x25 unchanged (still base)
    --   addi x26, x26, 256 -> x26 = base + 256
    --   addi x27, x27, 512 -> x27 = base + 512
    -- For simulation we assume x25/x26/x27 start at 0
    -- after reset, and A[0] is stored at word address 0
    -- in dmem.hex. Adjust if your memory map differs.
    -------------------------------------------------------

    -- addi x25, x25, 0  (x25 = x25 + 0, establishes base of A)
    wait until falling_edge(s_clk_dp);
    s_rd_address      <= "11001";  -- x25
    s_rs1_address     <= "11001";  -- x25
    s_rs2_address     <= "00000";  -- unused
    s_immediate_value <= x"000";   -- 0
    s_ALUsrc          <= '1';      -- use immediate
    s_add_sub_select  <= '0';      -- add
    s_write_enable    <= '1';
    s_MemWrite        <= '0';
    s_MemToReg        <= '0';      -- ALU result -> register

    -- addi x26, x26, 256  (x26 = x26 + 256, base of B)
    wait until falling_edge(s_clk_dp);
    s_rd_address      <= "11010";  -- x26
    s_rs1_address     <= "11010";  -- x26
    s_immediate_value <= x"100";   -- 256

    -- addi x27, x27, 512  (x27 = x27 + 512, for final store)
    wait until falling_edge(s_clk_dp);
    s_rd_address      <= "11011";  -- x27
    s_rs1_address     <= "11011";  -- x27
    s_immediate_value <= x"200";   -- 512

    -------------------------------------------------------
    -- lw x1, 0(x25)  -> x1 = A[0]
    -- ALU computes x25 + 0 as memory address
    -------------------------------------------------------
    wait until falling_edge(s_clk_dp);
    s_rd_address      <= "00001";  -- x1
    s_rs1_address     <= "11001";  -- x25
    s_rs2_address     <= "00000";  -- unused
    s_immediate_value <= x"000";   -- word offset 0
    s_ALUsrc          <= '1';      -- add immediate to base
    s_add_sub_select  <= '0';      -- add
    s_write_enable    <= '1';
    s_MemWrite        <= '0';
    s_MemToReg        <= '1';      -- memory data -> register

    -- lw x2, 4(x25)  -> x2 = A[1]  (word offset 1)
    wait until falling_edge(s_clk_dp);
    s_rd_address      <= "00010";  -- x2
    s_rs1_address     <= "11001";  -- x25
    s_immediate_value <= x"001";   -- word offset 1

    -------------------------------------------------------
    -- add x1, x1, x2  -> x1 = A[0] + A[1]
    -------------------------------------------------------
    wait until falling_edge(s_clk_dp);
    s_rd_address      <= "00001";  -- x1
    s_rs1_address     <= "00001";  -- x1
    s_rs2_address     <= "00010";  -- x2
    s_ALUsrc          <= '0';      -- use register (rs2)
    s_add_sub_select  <= '0';      -- add
    s_write_enable    <= '1';
    s_MemWrite        <= '0';
    s_MemToReg        <= '0';      -- ALU result -> register

    -------------------------------------------------------
    -- sw x1, 0(x26)  -> B[0] = x1
    -- rs1=x26 (address base), rs2=x1 (data), imm=0
    -------------------------------------------------------
    wait until falling_edge(s_clk_dp);
    s_rs1_address     <= "11010";  -- x26
    s_rs2_address     <= "00001";  -- x1
    s_immediate_value <= x"000";   -- word offset 0
    s_ALUsrc          <= '1';      -- add immediate to base for address
    s_add_sub_select  <= '0';
    s_write_enable    <= '0';      -- no register write
    s_MemWrite        <= '1';      -- write to memory
    s_MemToReg        <= '0';

    -------------------------------------------------------
    -- lw x2, 8(x25)  -> x2 = A[2]  (word offset 2)
    -------------------------------------------------------
    wait until falling_edge(s_clk_dp);
    s_rd_address      <= "00010";  -- x2
    s_rs1_address     <= "11001";  -- x25
    s_immediate_value <= x"002";   -- word offset 2
    s_ALUsrc          <= '1';
    s_write_enable    <= '1';
    s_MemWrite        <= '0';
    s_MemToReg        <= '1';

    -------------------------------------------------------
    -- add x1, x1, x2  -> x1 = x1 + A[2]
    -------------------------------------------------------
    wait until falling_edge(s_clk_dp);
    s_rd_address      <= "00001";
    s_rs1_address     <= "00001";
    s_rs2_address     <= "00010";
    s_ALUsrc          <= '0';
    s_write_enable    <= '1';
    s_MemWrite        <= '0';
    s_MemToReg        <= '0';

    -------------------------------------------------------
    -- sw x1, 4(x26)  -> B[1] = x1  (word offset 1)
    -------------------------------------------------------
    wait until falling_edge(s_clk_dp);
    s_rs1_address     <= "11010";  -- x26
    s_rs2_address     <= "00001";  -- x1
    s_immediate_value <= x"001";   -- word offset 1
    s_ALUsrc          <= '1';
    s_write_enable    <= '0';
    s_MemWrite        <= '1';
    s_MemToReg        <= '0';

    -------------------------------------------------------
    -- lw x2, 12(x25)  -> x2 = A[3]  (word offset 3)
    -------------------------------------------------------
    wait until falling_edge(s_clk_dp);
    s_rd_address      <= "00010";
    s_rs1_address     <= "11001";
    s_immediate_value <= x"003";   -- word offset 3
    s_ALUsrc          <= '1';
    s_write_enable    <= '1';
    s_MemWrite        <= '0';
    s_MemToReg        <= '1';

    -------------------------------------------------------
    -- add x1, x1, x2  -> x1 = x1 + A[3]
    -------------------------------------------------------
    wait until falling_edge(s_clk_dp);
    s_rd_address      <= "00001";
    s_rs1_address     <= "00001";
    s_rs2_address     <= "00010";
    s_ALUsrc          <= '0';
    s_write_enable    <= '1';
    s_MemWrite        <= '0';
    s_MemToReg        <= '0';

    -------------------------------------------------------
    -- sw x1, 8(x26)  -> B[2] = x1  (word offset 2)
    -------------------------------------------------------
    wait until falling_edge(s_clk_dp);
    s_rs1_address     <= "11010";
    s_rs2_address     <= "00001";
    s_immediate_value <= x"002";   -- word offset 2
    s_ALUsrc          <= '1';
    s_write_enable    <= '0';
    s_MemWrite        <= '1';
    s_MemToReg        <= '0';

    -------------------------------------------------------
    -- lw x2, 16(x25)  -> x2 = A[4]  (word offset 4)
    -------------------------------------------------------
    wait until falling_edge(s_clk_dp);
    s_rd_address      <= "00010";
    s_rs1_address     <= "11001";
    s_immediate_value <= x"004";   -- word offset 4
    s_ALUsrc          <= '1';
    s_write_enable    <= '1';
    s_MemWrite        <= '0';
    s_MemToReg        <= '1';

    -------------------------------------------------------
    -- add x1, x1, x2  -> x1 = x1 + A[4]
    -------------------------------------------------------
    wait until falling_edge(s_clk_dp);
    s_rd_address      <= "00001";
    s_rs1_address     <= "00001";
    s_rs2_address     <= "00010";
    s_ALUsrc          <= '0';
    s_write_enable    <= '1';
    s_MemWrite        <= '0';
    s_MemToReg        <= '0';

    -------------------------------------------------------
    -- sw x1, 12(x26)  -> B[3] = x1  (word offset 3)
    -------------------------------------------------------
    wait until falling_edge(s_clk_dp);
    s_rs1_address     <= "11010";
    s_rs2_address     <= "00001";
    s_immediate_value <= x"003";   -- word offset 3
    s_ALUsrc          <= '1';
    s_write_enable    <= '0';
    s_MemWrite        <= '1';
    s_MemToReg        <= '0';

    -------------------------------------------------------
    -- lw x2, 20(x25)  -> x2 = A[5]  (word offset 5)
    -------------------------------------------------------
    wait until falling_edge(s_clk_dp);
    s_rd_address      <= "00010";
    s_rs1_address     <= "11001";
    s_immediate_value <= x"005";   -- word offset 5
    s_ALUsrc          <= '1';
    s_write_enable    <= '1';
    s_MemWrite        <= '0';
    s_MemToReg        <= '1';

    -------------------------------------------------------
    -- add x1, x1, x2  -> x1 = x1 + A[5]
    -------------------------------------------------------
    wait until falling_edge(s_clk_dp);
    s_rd_address      <= "00001";
    s_rs1_address     <= "00001";
    s_rs2_address     <= "00010";
    s_ALUsrc          <= '0';
    s_write_enable    <= '1';
    s_MemWrite        <= '0';
    s_MemToReg        <= '0';

    -------------------------------------------------------
    -- sw x1, 16(x26)  -> B[4] = x1  (word offset 4)
    -------------------------------------------------------
    wait until falling_edge(s_clk_dp);
    s_rs1_address     <= "11010";
    s_rs2_address     <= "00001";
    s_immediate_value <= x"004";   -- word offset 4
    s_ALUsrc          <= '1';
    s_write_enable    <= '0';
    s_MemWrite        <= '1';
    s_MemToReg        <= '0';

    -------------------------------------------------------
    -- lw x2, 24(x25)  -> x2 = A[6]  (word offset 6)
    -------------------------------------------------------
    wait until falling_edge(s_clk_dp);
    s_rd_address      <= "00010";
    s_rs1_address     <= "11001";
    s_immediate_value <= x"006";   -- word offset 6
    s_ALUsrc          <= '1';
    s_write_enable    <= '1';
    s_MemWrite        <= '0';
    s_MemToReg        <= '1';

    -------------------------------------------------------
    -- add x1, x1, x2  -> x1 = x1 + A[6]
    -------------------------------------------------------
    wait until falling_edge(s_clk_dp);
    s_rd_address      <= "00001";
    s_rs1_address     <= "00001";
    s_rs2_address     <= "00010";
    s_ALUsrc          <= '0';
    s_add_sub_select  <= '0';
    s_write_enable    <= '1';
    s_MemWrite        <= '0';
    s_MemToReg        <= '0';

    -------------------------------------------------------
    -- addi x27, x27, 512  (x27 = x27 + 512)
    -- Lab lists this again here before the final store
    -------------------------------------------------------
    wait until falling_edge(s_clk_dp);
    s_rd_address      <= "11011";  -- x27
    s_rs1_address     <= "11011";  -- x27
    s_immediate_value <= x"200";   -- 512
    s_ALUsrc          <= '1';
    s_add_sub_select  <= '0';
    s_write_enable    <= '1';
    s_MemWrite        <= '0';
    s_MemToReg        <= '0';

    -------------------------------------------------------
    -- sw x1, -4(x27)  -> B[63] = x1
    -- -4 byte = word offset -1
    -- -1 in 12-bit two's complement = x"FFF"
    -- Sign-extends to 0xFFFFFFFF (-1), so address = x27 - 1
    -------------------------------------------------------
    wait until falling_edge(s_clk_dp);
    s_rs1_address     <= "11011";  -- x27
    s_rs2_address     <= "00001";  -- x1 (data to store)
    s_immediate_value <= x"FFF";   -- word offset -1
    s_ALUsrc          <= '1';
    s_add_sub_select  <= '0';
    s_write_enable    <= '0';
    s_MemWrite        <= '1';
    s_MemToReg        <= '0';

    -- Second sw x1, -4(x27)  (lab lists this instruction twice)
    wait until falling_edge(s_clk_dp);
    -- all signals unchanged, repeat the store

    -------------------------------------------------------
    -- Cleanup
    -------------------------------------------------------
    wait until falling_edge(s_clk_dp);
    s_MemWrite        <= '0';
    s_write_enable    <= '0';

    wait for cCLK_PER * 2;
    wait;
  end process;

end behavioral;