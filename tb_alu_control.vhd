-------------------------------------------------------------------------
-- Jay Patel
-- tb_alu_control.vhd
--
-- Testbench for alu_control.vhd
-- Covers:
--   ALUOp=00 -> ADD  (load/store, funct fields don't matter)
--   ALUOp=01 -> SUB  (branch, funct fields don't matter)
--   ALUOp=10 -> R-type decode (all 10 operations)
--   ALUOp=11 -> I-type decode (all 9 immediate operations)
--
-- Expected o_ALUCtrl values:
--   ADD=0000  SUB=0001  AND=0010  OR=0011
--   XOR=0100  SLT=0101  SLTU=0110 SLL=0111
--   SRL=1000  SRA=1001
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_alu_control is
  generic(gCLK_HPER : time := 10 ns);
end tb_alu_control;

architecture behavior of tb_alu_control is

  constant cCLK_PER : time := gCLK_HPER * 2;

  component alu_control is
    port(
      i_ALUOp    : in  std_logic_vector(1 downto 0);
      i_funct3   : in  std_logic_vector(2 downto 0);
      i_funct7_5 : in  std_logic;
      o_ALUCtrl  : out std_logic_vector(3 downto 0)
    );
  end component;

  -- Inputs
  signal s_ALUOp    : std_logic_vector(1 downto 0) := "00";
  signal s_funct3   : std_logic_vector(2 downto 0) := "000";
  signal s_funct7_5 : std_logic := '0';

  -- Output
  signal s_ALUCtrl  : std_logic_vector(3 downto 0);

begin

  DUT: alu_control
    port map(
      i_ALUOp    => s_ALUOp,
      i_funct3   => s_funct3,
      i_funct7_5 => s_funct7_5,
      o_ALUCtrl  => s_ALUCtrl
    );

  P_TEST: process
  begin

    -----------------------------------------------------------------------
    -- Group 1: ALUOp = "00"  (loads and stores -> ADD regardless of funct)
    -----------------------------------------------------------------------

    -- lw/sw: funct3 and funct7_5 are don't-care, result must always be ADD
    s_ALUOp <= "00"; s_funct3 <= "000"; s_funct7_5 <= '0';
    wait for cCLK_PER;
    -- expect o_ALUCtrl = "0000"  (ADD)

    s_ALUOp <= "00"; s_funct3 <= "010"; s_funct7_5 <= '1';
    wait for cCLK_PER;
    -- expect o_ALUCtrl = "0000"  (ADD -- funct fields ignored)

    -----------------------------------------------------------------------
    -- Group 2: ALUOp = "01"  (branches -> SUB regardless of funct)
    -----------------------------------------------------------------------

    s_ALUOp <= "01"; s_funct3 <= "000"; s_funct7_5 <= '0';
    wait for cCLK_PER;
    -- expect o_ALUCtrl = "0001"  (SUB -- beq comparison)

    s_ALUOp <= "01"; s_funct3 <= "101"; s_funct7_5 <= '0';
    wait for cCLK_PER;
    -- expect o_ALUCtrl = "0001"  (SUB -- bge comparison, funct ignored)

    -----------------------------------------------------------------------
    -- Group 3: ALUOp = "10"  (R-type, full funct3 + funct7_5 decode)
    -----------------------------------------------------------------------

    -- ADD : funct3=000 funct7_5=0
    s_ALUOp <= "10"; s_funct3 <= "000"; s_funct7_5 <= '0';
    wait for cCLK_PER;
    -- expect o_ALUCtrl = "0000"

    -- SUB : funct3=000 funct7_5=1
    s_ALUOp <= "10"; s_funct3 <= "000"; s_funct7_5 <= '1';
    wait for cCLK_PER;
    -- expect o_ALUCtrl = "0001"

    -- SLL : funct3=001 funct7_5=0
    s_ALUOp <= "10"; s_funct3 <= "001"; s_funct7_5 <= '0';
    wait for cCLK_PER;
    -- expect o_ALUCtrl = "0111"

    -- SLT : funct3=010 funct7_5=0
    s_ALUOp <= "10"; s_funct3 <= "010"; s_funct7_5 <= '0';
    wait for cCLK_PER;
    -- expect o_ALUCtrl = "0101"

    -- SLTU : funct3=011 funct7_5=0
    s_ALUOp <= "10"; s_funct3 <= "011"; s_funct7_5 <= '0';
    wait for cCLK_PER;
    -- expect o_ALUCtrl = "0110"

    -- XOR : funct3=100 funct7_5=0
    s_ALUOp <= "10"; s_funct3 <= "100"; s_funct7_5 <= '0';
    wait for cCLK_PER;
    -- expect o_ALUCtrl = "0100"

    -- SRL : funct3=101 funct7_5=0
    s_ALUOp <= "10"; s_funct3 <= "101"; s_funct7_5 <= '0';
    wait for cCLK_PER;
    -- expect o_ALUCtrl = "1000"

    -- SRA : funct3=101 funct7_5=1
    s_ALUOp <= "10"; s_funct3 <= "101"; s_funct7_5 <= '1';
    wait for cCLK_PER;
    -- expect o_ALUCtrl = "1001"

    -- OR  : funct3=110 funct7_5=0
    s_ALUOp <= "10"; s_funct3 <= "110"; s_funct7_5 <= '0';
    wait for cCLK_PER;
    -- expect o_ALUCtrl = "0011"

    -- AND : funct3=111 funct7_5=0
    s_ALUOp <= "10"; s_funct3 <= "111"; s_funct7_5 <= '0';
    wait for cCLK_PER;
    -- expect o_ALUCtrl = "0010"

    -----------------------------------------------------------------------
    -- Group 4: ALUOp = "11"  (I-type ALU, funct3 decode, funct7_5 for shifts)
    -----------------------------------------------------------------------

    -- ADDI  : funct3=000
    s_ALUOp <= "11"; s_funct3 <= "000"; s_funct7_5 <= '0';
    wait for cCLK_PER;
    -- expect o_ALUCtrl = "0000"

    -- SLLI  : funct3=001 funct7_5=0
    s_ALUOp <= "11"; s_funct3 <= "001"; s_funct7_5 <= '0';
    wait for cCLK_PER;
    -- expect o_ALUCtrl = "0111"

    -- SLTI  : funct3=010
    s_ALUOp <= "11"; s_funct3 <= "010"; s_funct7_5 <= '0';
    wait for cCLK_PER;
    -- expect o_ALUCtrl = "0101"

    -- SLTIU : funct3=011
    s_ALUOp <= "11"; s_funct3 <= "011"; s_funct7_5 <= '0';
    wait for cCLK_PER;
    -- expect o_ALUCtrl = "0110"

    -- XORI  : funct3=100
    s_ALUOp <= "11"; s_funct3 <= "100"; s_funct7_5 <= '0';
    wait for cCLK_PER;
    -- expect o_ALUCtrl = "0100"

    -- SRLI  : funct3=101 funct7_5=0
    s_ALUOp <= "11"; s_funct3 <= "101"; s_funct7_5 <= '0';
    wait for cCLK_PER;
    -- expect o_ALUCtrl = "1000"

    -- SRAI  : funct3=101 funct7_5=1
    s_ALUOp <= "11"; s_funct3 <= "101"; s_funct7_5 <= '1';
    wait for cCLK_PER;
    -- expect o_ALUCtrl = "1001"

    -- ORI   : funct3=110
    s_ALUOp <= "11"; s_funct3 <= "110"; s_funct7_5 <= '0';
    wait for cCLK_PER;
    -- expect o_ALUCtrl = "0011"

    -- ANDI  : funct3=111
    s_ALUOp <= "11"; s_funct3 <= "111"; s_funct7_5 <= '0';
    wait for cCLK_PER;
    -- expect o_ALUCtrl = "0010"

    -----------------------------------------------------------------------
    -- Edge case: bad/undefined combination -> default "1111"
    -----------------------------------------------------------------------
    s_ALUOp <= "10"; s_funct3 <= "001"; s_funct7_5 <= '1';
    wait for cCLK_PER;
    -- expect o_ALUCtrl = "1111"  (undefined R-type combo)

    wait;
  end process;

end behavior;
