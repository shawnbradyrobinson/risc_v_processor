-------------------------------------------------------------------------
-- Jay Patel
-- control_unit.vhd
--
-- Main control unit for RISC-V single-cycle processor.
-- Decodes the 7-bit opcode and drives all datapath control signals.
--
-- Supported opcodes (section 3.1 baseline):
--   R-type  : 0110011  (add, sub, and, or, xor, slt, sltu, sll, srl, sra)
--   I-ALU   : 0010011  (addi, andi, ori, xori, slti, sltiu, slli, srli, srai)
--   Load    : 0000011  (lw, lh, lb, lhu, lbu)
--   Store   : 0100011  (sw)
--   Branch  : 1100011  (beq, bne, blt, bge, bltu, bgeu)
--   JAL     : 1101111
--   JALR    : 1100111
--   LUI     : 0110111
--   AUIPC   : 0010111
--
-- ALUOp encoding (feeds into alu_control.vhd):
--   "00" = force ADD         (loads, stores)
--   "01" = force SUB         (branches -- for comparison)
--   "10" = R-type decode     (use funct3 + funct7)
--   "11" = I-type ALU decode (use funct3 only)
--
-- NOTE: o_MemToReg will be expanded to 2-bits later when JAL/JALR
--       need to write PC+4 back to rd.  For now it is 1-bit:
--         '0' = ALU result    '1' = data memory
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity control_unit is
  port(
    i_opcode   : in  std_logic_vector(6 downto 0);  -- instruction [6:0]

    o_ALUSrc   : out std_logic;                      -- 0=rs2  1=imm
    o_MemToReg : out std_logic;                      -- 0=ALU  1=mem
    o_RegWrite : out std_logic;                      -- 1=write rd
    o_MemRead  : out std_logic;                      -- 1=read  data mem
    o_MemWrite : out std_logic;                      -- 1=write data mem
    o_Branch   : out std_logic;                      -- 1=conditional branch
    o_Jump     : out std_logic;                      -- 1=unconditional jump (jal/jalr)
    o_ALUOp    : out std_logic_vector(1 downto 0)    -- ALU operation selector
  );
end control_unit;

architecture dataflow of control_unit is

  -----------------------------------------------------------------------
  -- Internal packed control word
  -- Bit layout (MSB -> LSB):
  --   [8]    ALUSrc
  --   [7]    MemToReg
  --   [6]    RegWrite
  --   [5]    MemRead
  --   [4]    MemWrite
  --   [3]    Branch
  --   [2]    Jump
  --   [1:0]  ALUOp
  -----------------------------------------------------------------------
  signal s_ctrl : std_logic_vector(8 downto 0);

begin

  -----------------------------------------------------------------------
  -- Decode: one-hot on opcode -> packed control word
  --
  --  Format:  ALUSrc & MemToReg & RegWrite & MemRead & MemWrite
  --           & Branch & Jump & ALUOp(1) & ALUOp(0)
  -----------------------------------------------------------------------
  with i_opcode select
    s_ctrl <=
      -- R-type:  ALUSrc=0 MTR=0 RW=1 MR=0 MW=0 Br=0 Jmp=0 ALUOp=10
      "001000010" when "0110011",

      -- I-ALU:   ALUSrc=1 MTR=0 RW=1 MR=0 MW=0 Br=0 Jmp=0 ALUOp=11
      "101000011" when "0010011",

      -- Load:    ALUSrc=1 MTR=1 RW=1 MR=1 MW=0 Br=0 Jmp=0 ALUOp=00
      "111100000" when "0000011",

      -- Store:   ALUSrc=1 MTR=0 RW=0 MR=0 MW=1 Br=0 Jmp=0 ALUOp=00
      "100010000" when "0100011",

      -- Branch:  ALUSrc=0 MTR=0 RW=0 MR=0 MW=0 Br=1 Jmp=0 ALUOp=01
      "000001001" when "1100011",

      -- JAL:     ALUSrc=0 MTR=0 RW=1 MR=0 MW=0 Br=0 Jmp=1 ALUOp=00
      --          (PC+4 written to rd -- MemToReg will become 2-bit later)
      "001000100" when "1101111",

      -- JALR:    ALUSrc=1 MTR=0 RW=1 MR=0 MW=0 Br=0 Jmp=1 ALUOp=00
      "101000100" when "1100111",

      -- LUI:     ALUSrc=1 MTR=0 RW=1 MR=0 MW=0 Br=0 Jmp=0 ALUOp=11
      "101000011" when "0110111",

      -- AUIPC:   ALUSrc=1 MTR=0 RW=1 MR=0 MW=0 Br=0 Jmp=0 ALUOp=11
      "101000011" when "0010111",

      -- Default (unknown opcode): all disabled
      "000000000" when others;

  -----------------------------------------------------------------------
  -- Unpack control word to individual output ports
  -----------------------------------------------------------------------
  o_ALUSrc   <= s_ctrl(8);
  o_MemToReg <= s_ctrl(7);
  o_RegWrite <= s_ctrl(6);
  o_MemRead  <= s_ctrl(5);
  o_MemWrite <= s_ctrl(4);
  o_Branch   <= s_ctrl(3);
  o_Jump     <= s_ctrl(2);
  o_ALUOp    <= s_ctrl(1 downto 0);

end dataflow;
