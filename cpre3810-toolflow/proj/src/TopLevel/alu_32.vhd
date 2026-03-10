
-- Jay Patel
-- alu_32.vhd


library IEEE;
use IEEE.std_logic_1164.all;

entity alu_32 is
  port(
    i_A      : in  std_logic_vector(31 downto 0);  -- operand A (rs1)
    i_B      : in  std_logic_vector(31 downto 0);  -- operand B (rs2 or imm)
    i_ALUCtrl: in  std_logic_vector(3  downto 0);  -- from alu_control.vhd

    o_Result : out std_logic_vector(31 downto 0);
    o_Zero   : out std_logic                        -- 1 when result == 0
  );
end alu_32;

architecture structural of alu_32 is

 
  -- Component declarations


  component addsub_32 is
    port(
      i_A        : in  std_logic_vector(31 downto 0);
      i_B        : in  std_logic_vector(31 downto 0);
      i_nAdd_Sub : in  std_logic;
      o_Sum      : out std_logic_vector(31 downto 0);
      o_Cout     : out std_logic;
      o_Overflow : out std_logic;
      o_SLT      : out std_logic_vector(31 downto 0);
      o_SLTU     : out std_logic_vector(31 downto 0)
    );
  end component;

  component barrel_shifter is
    port(
      i_A     : in  std_logic_vector(31 downto 0);
      i_shamt : in  std_logic_vector(4  downto 0);
      i_arith : in  std_logic;
      i_left  : in  std_logic;
      o_result: out std_logic_vector(31 downto 0)
    );
  end component;

  component andg2 is
    port(i_A : in std_logic; i_B : in std_logic; o_F : out std_logic);
  end component;

  component org2 is
    port(i_A : in std_logic; i_B : in std_logic; o_F : out std_logic);
  end component;

  component xorg2 is
    port(i_A : in std_logic; i_B : in std_logic; o_F : out std_logic);
  end component;

  component invg is
    port(i_A : in std_logic; o_F : out std_logic);
  end component;


  -- Internal signals ? results from each functional unit
  

  signal s_add_result  : std_logic_vector(31 downto 0);  -- ADD result
  signal s_sub_result  : std_logic_vector(31 downto 0);  -- SUB result
  signal s_slt_result  : std_logic_vector(31 downto 0);  -- SLT result
  signal s_sltu_result : std_logic_vector(31 downto 0);  -- SLTU result
  signal s_sll_result  : std_logic_vector(31 downto 0);  -- SLL result
  signal s_srl_result  : std_logic_vector(31 downto 0);  -- SRL result
  signal s_sra_result  : std_logic_vector(31 downto 0);  -- SRA result
  signal s_and_result  : std_logic_vector(31 downto 0);  -- AND result
  signal s_or_result   : std_logic_vector(31 downto 0);  -- OR  result
  signal s_xor_result  : std_logic_vector(31 downto 0);  -- XOR result
  signal s_nor_result  : std_logic_vector(31 downto 0);  -- NOR result

  -- addsub shared outputs
  signal s_Cout_add   : std_logic;
  signal s_Cout_sub   : std_logic;
  signal s_Ovf_add    : std_logic;
  signal s_Ovf_sub    : std_logic;

  -- barrel shifter control
  signal s_shamt      : std_logic_vector(4 downto 0);

  -- output mux result (before zero flag)
  signal s_result     : std_logic_vector(31 downto 0);

  -- zero flag chain
  signal s_or_chain   : std_logic_vector(31 downto 0);

begin

 
  -- SHIFT AMOUNT always comes from lower 5 bits of i_B
    s_shamt <= i_B(4 downto 0);

  
  -- ADDER/SUBTRACTOR  ADD path
  --   i_nAdd_Sub = 0                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    ADD
  
  ADDER_INST: addsub_32
    port map(
      i_A        => i_A,
      i_B        => i_B,
      i_nAdd_Sub => '0',
      o_Sum      => s_add_result,
      o_Cout     => s_Cout_add,
      o_Overflow => s_Ovf_add,
      o_SLT      => open,
      o_SLTU     => open
    );

  
  -- ADDER/SUBTRACTOR  SUB path (also generates SLT and SLTU)
  --   i_nAdd_Sub = 1  SUB
 
  SUBBER_INST: addsub_32
    port map(
      i_A        => i_A,
      i_B        => i_B,
      i_nAdd_Sub => '1',
      o_Sum      => s_sub_result,
      o_Cout     => s_Cout_sub,
      o_Overflow => s_Ovf_sub,
      o_SLT      => s_slt_result,
      o_SLTU     => s_sltu_result
    );

   -- BARREL SHIFTER  SLL (left logical)
  --   i_arith=0  i_left=1
 
  SHIFT_LEFT: barrel_shifter
    port map(
      i_A      => i_A,
      i_shamt  => s_shamt,
      i_arith  => '0',
      i_left   => '1',
      o_result => s_sll_result
    );

 
  -- BARREL SHIFTER  SRL (right logical)
  --   i_arith=0  i_left=0
  
  SHIFT_RIGHT_L: barrel_shifter
    port map(
      i_A      => i_A,
      i_shamt  => s_shamt,
      i_arith  => '0',
      i_left   => '0',
      o_result => s_srl_result
    );

  
  -- BARREL SHIFTER  SRA (right arithmetic)
  --   i_arith=1  i_left=0
   SHIFT_RIGHT_A: barrel_shifter
    port map(
      i_A      => i_A,
      i_shamt  => s_shamt,
      i_arith  => '1',
      i_left   => '0',
      o_result => s_sra_result
    );

   -- BITWISE AND ? structural generate loop (andg2 per bit)
  
  G_AND: for i in 0 to 31 generate
    AND_INST: andg2
      port map(i_A => i_A(i), i_B => i_B(i), o_F => s_and_result(i));
  end generate G_AND;

    -- BITWISE OR ? structural generate loop (org2 per bit)
  
  G_OR: for i in 0 to 31 generate
    OR_INST: org2
      port map(i_A => i_A(i), i_B => i_B(i), o_F => s_or_result(i));
  end generate G_OR;

   -- BITWISE XOR ? structural generate loop (xorg2 per bit)
  
  G_XOR: for i in 0 to 31 generate
    XOR_INST: xorg2
      port map(i_A => i_A(i), i_B => i_B(i), o_F => s_xor_result(i));
  end generate G_XOR;

   -- BITWISE NOR ? NOT(OR) using invg on each OR result bit
 
  G_NOR: for i in 0 to 31 generate
    NOR_INST: invg
      port map(i_A => s_or_result(i), o_F => s_nor_result(i));
  end generate G_NOR;

    -- OUTPUT MUX ? select result based on ALUCtrl (dataflow with/select)
  -- Encoding matches alu_control.vhd exactly.
   with i_ALUCtrl select
    s_result <=
      s_add_result  when "0000",   -- ADD / ADDI
      s_sub_result  when "0001",   -- SUB
      s_and_result  when "0010",   -- AND / ANDI
      s_or_result   when "0011",   -- OR  / ORI
      s_xor_result  when "0100",   -- XOR / XORI
      s_slt_result  when "0101",   -- SLT / SLTI
      s_sltu_result when "0110",   -- SLTU/ SLTIU
      s_sll_result  when "0111",   -- SLL / SLLI
      s_srl_result  when "1000",   -- SRL / SRLI
      s_sra_result  when "1001",   -- SRA / SRAI
      s_nor_result  when "1010",   -- NOR  (lab spec)
      (others => '0') when others;

  o_Result <= s_result;

  
  -- ZERO FLAG
  --   o_Zero = 1 when s_result = 0x00000000
  --   Structurally: OR-reduce all 32 bits, then invert.
  --   Uses a chain of org2 instances: s_or_chain(0) = result(0) OR result(1),
  --   s_or_chain(i) = s_or_chain(i-1) OR result(i+1), ..., finally invert.
  
  OR_CHAIN_0: org2
    port map(i_A => s_result(0), i_B => s_result(1), o_F => s_or_chain(0));

  G_OR_CHAIN: for i in 1 to 30 generate
    OR_Ci: org2
      port map(i_A => s_or_chain(i-1), i_B => s_result(i+1), o_F => s_or_chain(i));
  end generate G_OR_CHAIN;

  ZERO_INV: invg
    port map(i_A => s_or_chain(30), o_F => o_Zero);

end structural;