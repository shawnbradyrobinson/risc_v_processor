-------------------------------------------------------------------------
-- Jay Patel
-- alu_control.vhd
--
-- ALU control unit for RISC-V single-cycle processor.
-- Takes ALUOp from the main control unit + funct3 + funct7 bit 5
-- and outputs a 4-bit ALU operation code.
--
-- ALUOp from control_unit.vhd:
--   "00" -> ADD  (loads, stores)
--   "01" -> SUB  (branches)
--   "10" -> decode funct3 + funct7_5  (R-type)
--   "11" -> decode funct3 only        (I-type ALU: addi, xori, etc.)
--
-- o_ALUCtrl encoding:
--   "0000" = ADD
--   "0001" = SUB
--   "0010" = AND
--   "0011" = OR
--   "0100" = XOR
--   "0101" = SLT  (signed)
--   "0110" = SLTU (unsigned)
--   "0111" = SLL
--   "1000" = SRL
--   "1001" = SRA
--   "1010" = LUI passthrough (B input straight through -- used by datapath)
--   "1111" = default / undefined
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity alu_control is
  port(
    i_ALUOp   : in  std_logic_vector(1 downto 0);  -- from control_unit
    i_funct3  : in  std_logic_vector(2 downto 0);  -- instruction [14:12]
    i_funct7_5: in  std_logic;                      -- instruction bit 30 (funct7[5])

    o_ALUCtrl : out std_logic_vector(3 downto 0)   -- to ALU operation select
  );
end alu_control;

architecture dataflow of alu_control is

  -----------------------------------------------------------------------
  -- Combine inputs into one select key:
  --   key = ALUOp(1) & ALUOp(0) & funct3(2) & funct3(1) & funct3(0) & funct7_5
  --   6 bits total
  -----------------------------------------------------------------------
  signal s_key : std_logic_vector(5 downto 0);

begin

  s_key <= i_ALUOp & i_funct3 & i_funct7_5;

  -----------------------------------------------------------------------
  -- Decode
  --
  -- When ALUOp = "00" (loads/stores) -> always ADD, funct fields ignored
  -- When ALUOp = "01" (branches)     -> always SUB, funct fields ignored
  -- When ALUOp = "10" (R-type)       -> full funct3 + funct7_5 decode
  -- When ALUOp = "11" (I-ALU)        -> funct3 decode, funct7_5 only for
  --                                      srai (funct3=101, funct7_5=1)
  -----------------------------------------------------------------------
  with s_key select
    o_ALUCtrl <=

      -------------------------------------------------------------------
      -- ALUOp = "00" : force ADD  (loads and stores)
      -- funct3/funct7 are don't-care so we cover all 16 combinations
      -------------------------------------------------------------------
      "0000" when "000000",
      "0000" when "000001",
      "0000" when "000010",
      "0000" when "000011",
      "0000" when "000100",
      "0000" when "000101",
      "0000" when "000110",
      "0000" when "000111",
      "0000" when "001000",
      "0000" when "001001",
      "0000" when "001010",
      "0000" when "001011",
      "0000" when "001100",
      "0000" when "001101",
      "0000" when "001110",
      "0000" when "001111",

      -------------------------------------------------------------------
      -- ALUOp = "01" : force SUB  (branches)
      -------------------------------------------------------------------
      "0001" when "010000",
      "0001" when "010001",
      "0001" when "010010",
      "0001" when "010011",
      "0001" when "010100",
      "0001" when "010101",
      "0001" when "010110",
      "0001" when "010111",
      "0001" when "011000",
      "0001" when "011001",
      "0001" when "011010",
      "0001" when "011011",
      "0001" when "011100",
      "0001" when "011101",
      "0001" when "011110",
      "0001" when "011111",

      -------------------------------------------------------------------
      -- ALUOp = "10" : R-type  (funct3 + funct7_5 decide operation)
      -------------------------------------------------------------------
      -- ADD  : funct3=000 funct7_5=0
      "0000" when "100000",
      -- SUB  : funct3=000 funct7_5=1
      "0001" when "100001",
      -- SLL  : funct3=001 funct7_5=0
      "0111" when "100010",
      -- SLT  : funct3=010 funct7_5=0
      "0101" when "100100",
      -- SLTU : funct3=011 funct7_5=0
      "0110" when "100110",
      -- XOR  : funct3=100 funct7_5=0
      "0100" when "101000",
      -- SRL  : funct3=101 funct7_5=0
      "1000" when "101010",
      -- SRA  : funct3=101 funct7_5=1
      "1001" when "101011",
      -- OR   : funct3=110 funct7_5=0
      "0011" when "101100",
      -- AND  : funct3=111 funct7_5=0
      "0010" when "101110",

      -------------------------------------------------------------------
      -- ALUOp = "11" : I-type ALU  (immediate versions)
      -------------------------------------------------------------------
      -- ADDI  : funct3=000
      "0000" when "110000",
      "0000" when "110001",
      -- SLLI  : funct3=001 funct7_5=0
      "0111" when "110010",
      -- SLTI  : funct3=010
      "0101" when "110100",
      "0101" when "110101",
      -- SLTIU : funct3=011
      "0110" when "110110",
      "0110" when "110111",
      -- XORI  : funct3=100
      "0100" when "111000",
      "0100" when "111001",
      -- SRLI  : funct3=101 funct7_5=0
      "1000" when "111010",
      -- SRAI  : funct3=101 funct7_5=1
      "1001" when "111011",
      -- ORI   : funct3=110
      "0011" when "111100",
      "0011" when "111101",
      -- ANDI  : funct3=111
      "0010" when "111110",
      "0010" when "111111",

      -------------------------------------------------------------------
      -- Default
      -------------------------------------------------------------------
      "1111" when others;

end dataflow;
