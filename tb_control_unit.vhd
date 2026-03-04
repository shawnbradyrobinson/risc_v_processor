-------------------------------------------------------------------------
-- Jay Patel
-- tb_control_unit.vhd
--
-- Testbench for control_unit.vhd
-- Tests every supported opcode and verifies each output signal.
-- Checks are written as comments so you can confirm in waveform.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_control_unit is
  generic(gCLK_HPER : time := 10 ns);
end tb_control_unit;

architecture behavior of tb_control_unit is

  constant cCLK_PER : time := gCLK_HPER * 2;

  component control_unit is
    port(
      i_opcode   : in  std_logic_vector(6 downto 0);
      o_ALUSrc   : out std_logic;
      o_MemToReg : out std_logic;
      o_RegWrite : out std_logic;
      o_MemRead  : out std_logic;
      o_MemWrite : out std_logic;
      o_Branch   : out std_logic;
      o_Jump     : out std_logic;
      o_ALUOp    : out std_logic_vector(1 downto 0)
    );
  end component;

  -- Inputs
  signal s_opcode   : std_logic_vector(6 downto 0) := "0000000";

  -- Outputs
  signal s_ALUSrc   : std_logic;
  signal s_MemToReg : std_logic;
  signal s_RegWrite : std_logic;
  signal s_MemRead  : std_logic;
  signal s_MemWrite : std_logic;
  signal s_Branch   : std_logic;
  signal s_Jump     : std_logic;
  signal s_ALUOp    : std_logic_vector(1 downto 0);

begin

  DUT: control_unit
    port map(
      i_opcode   => s_opcode,
      o_ALUSrc   => s_ALUSrc,
      o_MemToReg => s_MemToReg,
      o_RegWrite => s_RegWrite,
      o_MemRead  => s_MemRead,
      o_MemWrite => s_MemWrite,
      o_Branch   => s_Branch,
      o_Jump     => s_Jump,
      o_ALUOp    => s_ALUOp
    );

  P_TEST: process
  begin

    -----------------------------------------------------------------------
    -- Test 1: R-type (add, sub, and, or, xor, slt, sll, srl, sra)
    -- opcode = 0110011
    -- Expect: ALUSrc=0 MTR=0 RW=1 MR=0 MW=0 Br=0 Jmp=0 ALUOp=10
    -----------------------------------------------------------------------
    s_opcode <= "0110011";
    wait for cCLK_PER;
    -- check: s_ALUSrc='0', s_MemToReg='0', s_RegWrite='1'
    -- check: s_MemRead='0', s_MemWrite='0'
    -- check: s_Branch='0',  s_Jump='0', s_ALUOp="10"

    -----------------------------------------------------------------------
    -- Test 2: I-type ALU (addi, xori, ori, andi, slti, sltiu, slli, srli, srai)
    -- opcode = 0010011
    -- Expect: ALUSrc=1 MTR=0 RW=1 MR=0 MW=0 Br=0 Jmp=0 ALUOp=11
    -----------------------------------------------------------------------
    s_opcode <= "0010011";
    wait for cCLK_PER;
    -- check: s_ALUSrc='1', s_RegWrite='1', s_ALUOp="11"

    -----------------------------------------------------------------------
    -- Test 3: Load (lw, lh, lb, lhu, lbu)
    -- opcode = 0000011
    -- Expect: ALUSrc=1 MTR=1 RW=1 MR=1 MW=0 Br=0 Jmp=0 ALUOp=00
    -----------------------------------------------------------------------
    s_opcode <= "0000011";
    wait for cCLK_PER;
    -- check: s_ALUSrc='1', s_MemToReg='1', s_RegWrite='1'
    -- check: s_MemRead='1', s_MemWrite='0', s_ALUOp="00"

    -----------------------------------------------------------------------
    -- Test 4: Store (sw)
    -- opcode = 0100011
    -- Expect: ALUSrc=1 MTR=0 RW=0 MR=0 MW=1 Br=0 Jmp=0 ALUOp=00
    -----------------------------------------------------------------------
    s_opcode <= "0100011";
    wait for cCLK_PER;
    -- check: s_ALUSrc='1', s_RegWrite='0', s_MemWrite='1', s_ALUOp="00"

    -----------------------------------------------------------------------
    -- Test 5: Branch (beq, bne, blt, bge, bltu, bgeu)
    -- opcode = 1100011
    -- Expect: ALUSrc=0 MTR=0 RW=0 MR=0 MW=0 Br=1 Jmp=0 ALUOp=01
    -----------------------------------------------------------------------
    s_opcode <= "1100011";
    wait for cCLK_PER;
    -- check: s_ALUSrc='0', s_RegWrite='0', s_Branch='1', s_ALUOp="01"

    -----------------------------------------------------------------------
    -- Test 6: JAL
    -- opcode = 1101111
    -- Expect: ALUSrc=0 MTR=0 RW=1 MR=0 MW=0 Br=0 Jmp=1 ALUOp=00
    -----------------------------------------------------------------------
    s_opcode <= "1101111";
    wait for cCLK_PER;
    -- check: s_RegWrite='1', s_Jump='1', s_ALUOp="00"

    -----------------------------------------------------------------------
    -- Test 7: JALR
    -- opcode = 1100111
    -- Expect: ALUSrc=1 MTR=0 RW=1 MR=0 MW=0 Br=0 Jmp=1 ALUOp=00
    -----------------------------------------------------------------------
    s_opcode <= "1100111";
    wait for cCLK_PER;
    -- check: s_ALUSrc='1', s_RegWrite='1', s_Jump='1', s_ALUOp="00"

    -----------------------------------------------------------------------
    -- Test 8: LUI
    -- opcode = 0110111
    -- Expect: ALUSrc=1 MTR=0 RW=1 MR=0 MW=0 Br=0 Jmp=0 ALUOp=11
    -----------------------------------------------------------------------
    s_opcode <= "0110111";
    wait for cCLK_PER;
    -- check: s_ALUSrc='1', s_RegWrite='1', s_ALUOp="11"

    -----------------------------------------------------------------------
    -- Test 9: AUIPC
    -- opcode = 0010111
    -- Expect: ALUSrc=1 MTR=0 RW=1 MR=0 MW=0 Br=0 Jmp=0 ALUOp=11
    -----------------------------------------------------------------------
    s_opcode <= "0010111";
    wait for cCLK_PER;
    -- check: s_ALUSrc='1', s_RegWrite='1', s_ALUOp="11"

    -----------------------------------------------------------------------
    -- Test 10: Unknown opcode (default case)
    -- Expect: all signals = 0
    -----------------------------------------------------------------------
    s_opcode <= "1111111";
    wait for cCLK_PER;
    -- check: all outputs = 0, s_ALUOp="00"

    wait;
  end process;

end behavior;
