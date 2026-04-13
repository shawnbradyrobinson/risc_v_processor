
-- Jay Patel
-- tb_alu.vhd


library IEEE;
use IEEE.std_logic_1164.all;

entity tb_alu is
  generic(gCLK_HPER : time := 10 ns);
end tb_alu;

architecture behavior of tb_alu is

  constant cCLK_PER : time := gCLK_HPER * 2;

  component alu_32 is
    port(
      i_A       : in  std_logic_vector(31 downto 0);
      i_B       : in  std_logic_vector(31 downto 0);
      i_ALUCtrl : in  std_logic_vector(3  downto 0);
      o_Result  : out std_logic_vector(31 downto 0);
      o_Zero    : out std_logic
    );
  end component;

  -- inputs
  signal s_A       : std_logic_vector(31 downto 0) := (others => '0');
  signal s_B       : std_logic_vector(31 downto 0) := (others => '0');
  signal s_ALUCtrl : std_logic_vector(3  downto 0) := "0000";

  -- outputs
  signal s_Result  : std_logic_vector(31 downto 0);
  signal s_Zero    : std_logic;

begin

  DUT: alu_32
    port map(
      i_A       => s_A,
      i_B       => s_B,
      i_ALUCtrl => s_ALUCtrl,
      o_Result  => s_Result,
      o_Zero    => s_Zero
    );

  P_TEST: process
  begin

    --=====================================================================
    -- GROUP 1: ADD   ALUCtrl = 0000
    --=====================================================================

    -- Test 1a: basic addition  5 + 3 = 8
    s_ALUCtrl <= "0000";
    s_A <= x"00000005"; s_B <= x"00000003";
    wait for cCLK_PER;
    -- expect o_Result = 0x00000008  o_Zero = 0

    -- Test 1b: adding zero  7 + 0 = 7
    s_A <= x"00000007"; s_B <= x"00000000";
    wait for cCLK_PER;
    -- expect o_Result = 0x00000007  o_Zero = 0

    -- Test 1c: negative + positive  -1 + 1 = 0
    s_A <= x"FFFFFFFF"; s_B <= x"00000001";
    wait for cCLK_PER;
    -- expect o_Result = 0x00000000  o_Zero = 1

    -- Test 1d: max positive + 1 = overflow  0x7FFFFFFF + 1
    s_A <= x"7FFFFFFF"; s_B <= x"00000001";
    wait for cCLK_PER;
    -- expect o_Result = 0x80000000  (overflow -- result looks negative)

    -- Test 1e: two negatives  -3 + -4 = -7
    s_A <= x"FFFFFFFD"; s_B <= x"FFFFFFFC";
    wait for cCLK_PER;
    -- expect o_Result = 0xFFFFFFF9

    --=====================================================================
    -- GROUP 2: SUB   ALUCtrl = 0001
   -- =====================================================================

    -- Test 2a: basic  10 - 3 = 7
    s_ALUCtrl <= "0001";
    s_A <= x"0000000A"; s_B <= x"00000003";
    wait for cCLK_PER;
    -- expect o_Result = 0x00000007  o_Zero = 0

    -- Test 2b: A = B  5 - 5 = 0
    s_A <= x"00000005"; s_B <= x"00000005";
    wait for cCLK_PER;
    -- expect o_Result = 0x00000000  o_Zero = 1

    -- Test 2c: negative result  3 - 10 = -7
    s_A <= x"00000003"; s_B <= x"0000000A";
    wait for cCLK_PER;
    -- expect o_Result = 0xFFFFFFF9

    -- Test 2d: min negative - 1  0x80000000 - 1 = overflow
    s_A <= x"80000000"; s_B <= x"00000001";
    wait for cCLK_PER;
    -- expect o_Result = 0x7FFFFFFF  (overflow into positive)

    --=====================================================================
    -- GROUP 3: AND   ALUCtrl = 0010
   -- =====================================================================

    -- Test 3a: all ones AND all ones
    s_ALUCtrl <= "0010";
    s_A <= x"FFFFFFFF"; s_B <= x"FFFFFFFF";
    wait for cCLK_PER;
    -- expect o_Result = 0xFFFFFFFF

    -- Test 3b: alternating pattern  0xAAAAAAAA AND 0x55555555
    s_A <= x"AAAAAAAA"; s_B <= x"55555555";
    wait for cCLK_PER;
    -- expect o_Result = 0x00000000  o_Zero = 1

    -- Test 3c: mask lower byte  0xDEADBEEF AND 0x000000FF
    s_A <= x"DEADBEEF"; s_B <= x"000000FF";
    wait for cCLK_PER;
    -- expect o_Result = 0x000000EF

    -- Test 3d: AND with zero
    s_A <= x"FFFFFFFF"; s_B <= x"00000000";
    wait for cCLK_PER;
    -- expect o_Result = 0x00000000  o_Zero = 1

    --=====================================================================
    -- GROUP 4: OR   ALUCtrl = 0011
   -- =====================================================================

    -- Test 4a: OR with zero  (pass-through)
    s_ALUCtrl <= "0011";
    s_A <= x"DEADBEEF"; s_B <= x"00000000";
    wait for cCLK_PER;
    -- expect o_Result = 0xDEADBEEF

    -- Test 4b: OR with all-ones  (force all 1s)
    s_A <= x"00000000"; s_B <= x"FFFFFFFF";
    wait for cCLK_PER;
    -- expect o_Result = 0xFFFFFFFF

    -- Test 4c: partial overlap
    s_A <= x"0F0F0F0F"; s_B <= x"F0F0F0F0";
    wait for cCLK_PER;
    -- expect o_Result = 0xFFFFFFFF

   -- =====================================================================
    -- GROUP 5: XOR   ALUCtrl = 0100
   -- =====================================================================

    -- Test 5a: XOR same operands  (always zero)
    s_ALUCtrl <= "0100";
    s_A <= x"DEADBEEF"; s_B <= x"DEADBEEF";
    wait for cCLK_PER;
    -- expect o_Result = 0x00000000  o_Zero = 1

    -- Test 5b: XOR with all-ones  (bitwise NOT)
    s_A <= x"DEADBEEF"; s_B <= x"FFFFFFFF";
    wait for cCLK_PER;
    -- expect o_Result = 0x21524110

    -- Test 5c: alternating patterns
    s_A <= x"AAAAAAAA"; s_B <= x"55555555";
    wait for cCLK_PER;
    -- expect o_Result = 0xFFFFFFFF

    --=====================================================================
    -- GROUP 6: NOR   ALUCtrl = 1010
   -- =====================================================================

    -- Test 6a: NOR(0, 0) = 1 (all ones)
    s_ALUCtrl <= "1010";
    s_A <= x"00000000"; s_B <= x"00000000";
    wait for cCLK_PER;
    -- expect o_Result = 0xFFFFFFFF

    -- Test 6b: NOR(all-ones, 0) = 0
    s_A <= x"FFFFFFFF"; s_B <= x"00000000";
    wait for cCLK_PER;
    -- expect o_Result = 0x00000000  o_Zero = 1

    --=====================================================================
    -- GROUP 7: SLT (signed)   ALUCtrl = 0101
    --=====================================================================

    -- Test 7a: A < B signed  1 < 5  ? result = 1
    s_ALUCtrl <= "0101";
    s_A <= x"00000001"; s_B <= x"00000005";
    wait for cCLK_PER;
    -- expect o_Result = 0x00000001

    -- Test 7b: A > B signed  5 > 1  ? result = 0
    s_A <= x"00000005"; s_B <= x"00000001";
    wait for cCLK_PER;
    -- expect o_Result = 0x00000000  o_Zero = 1

    -- Test 7c: A = B  ? result = 0
    s_A <= x"00000005"; s_B <= x"00000005";
    wait for cCLK_PER;
    -- expect o_Result = 0x00000000  o_Zero = 1

    -- Test 7d: negative < positive  -1 < 1  ? result = 1
    s_A <= x"FFFFFFFF"; s_B <= x"00000001";
    wait for cCLK_PER;
    -- expect o_Result = 0x00000001

    -- Test 7e: positive < negative?  1 < -1  ? result = 0
    s_A <= x"00000001"; s_B <= x"FFFFFFFF";
    wait for cCLK_PER;
    -- expect o_Result = 0x00000000  o_Zero = 1

    -- Test 7f: overflow edge  0x80000000 < 0x7FFFFFFF (signed: -big < +big ? 1)
    s_A <= x"80000000"; s_B <= x"7FFFFFFF";
    wait for cCLK_PER;
    -- expect o_Result = 0x00000001

    --=====================================================================
    -- GROUP 8: SLTU (unsigned)   ALUCtrl = 0110
   -- =====================================================================

    -- Test 8a: 1 <u 5  ? result = 1
    s_ALUCtrl <= "0110";
    s_A <= x"00000001"; s_B <= x"00000005";
    wait for cCLK_PER;
    -- expect o_Result = 0x00000001

    -- Test 8b: 0xFFFFFFFF <u 0x00000001?  No, 0xFFFF > 1 unsigned ? 0
    s_A <= x"FFFFFFFF"; s_B <= x"00000001";
    wait for cCLK_PER;
    -- expect o_Result = 0x00000000  o_Zero = 1

    -- Test 8c: 0x00000001 <u 0xFFFFFFFF  ? result = 1
    s_A <= x"00000001"; s_B <= x"FFFFFFFF";
    wait for cCLK_PER;
    -- expect o_Result = 0x00000001

    --=====================================================================
    -- GROUP 9: SLL   ALUCtrl = 0111
    -- shamt comes from i_B[4:0]
   -- =====================================================================

    -- Test 9a: shift left by 0  (no change)
    s_ALUCtrl <= "0111";
    s_A <= x"00000001";
    s_B <= x"00000000";  -- shamt = 0
    wait for cCLK_PER;
    -- expect o_Result = 0x00000001

    -- Test 9b: shift left by 1  1 << 1 = 2
    s_A <= x"00000001"; s_B <= x"00000001";
    wait for cCLK_PER;
    -- expect o_Result = 0x00000002

    -- Test 9c: shift left by 8  0x000000FF << 8 = 0x0000FF00
    s_A <= x"000000FF"; s_B <= x"00000008";
    wait for cCLK_PER;
    -- expect o_Result = 0x0000FF00

    -- Test 9d: shift left by 16
    s_A <= x"000000FF"; s_B <= x"00000010";
    wait for cCLK_PER;
    -- expect o_Result = 0x00FF0000

    -- Test 9e: shift left by 31  1 << 31 = 0x80000000
    s_A <= x"00000001"; s_B <= x"0000001F";
    wait for cCLK_PER;
    -- expect o_Result = 0x80000000

    -- Test 9f: shift left losing bits  0xDEADBEEF << 4
    s_A <= x"DEADBEEF"; s_B <= x"00000004";
    wait for cCLK_PER;
    -- expect o_Result = 0xEADBEEF0

    --=====================================================================
    -- GROUP 10: SRL (logical right)   ALUCtrl = 1000
   -- =====================================================================

    -- Test 10a: shift right by 0  (no change)
    s_ALUCtrl <= "1000";
    s_A <= x"80000000"; s_B <= x"00000000";
    wait for cCLK_PER;
    -- expect o_Result = 0x80000000

    -- Test 10b: logical right by 1  0x80000000 >> 1 = 0x40000000  (fill=0)
    s_A <= x"80000000"; s_B <= x"00000001";
    wait for cCLK_PER;
    -- expect o_Result = 0x40000000  (NOT 0xC0000000, fill is 0)

    -- Test 10c: shift right by 8
    s_A <= x"DEADBEEF"; s_B <= x"00000008";
    wait for cCLK_PER;
    -- expect o_Result = 0x00DEADBE

    -- Test 10d: shift right by 31  all bits go to bit 0
    s_A <= x"FFFFFFFF"; s_B <= x"0000001F";
    wait for cCLK_PER;
    -- expect o_Result = 0x00000001

    --=====================================================================
    -- GROUP 11: SRA (arithmetic right)   ALUCtrl = 1001
    -- KEY: fill bit must be sign bit (i_A[31])
   -- =====================================================================

    -- Test 11a: positive number shift right arith by 1  (fill=0, same as SRL)
    s_ALUCtrl <= "1001";
    s_A <= x"40000000"; s_B <= x"00000001";
    wait for cCLK_PER;
    -- expect o_Result = 0x20000000  (fill=0 because bit31=0)

    -- Test 11b: negative number  0x80000000 >> 1  arith  (fill=1)
    s_A <= x"80000000"; s_B <= x"00000001";
    wait for cCLK_PER;
    -- expect o_Result = 0xC0000000  (fill=1, not 0x40000000!)

    -- Test 11c: SRA by 8  negative number stays negative
    s_A <= x"DEADBEEF"; s_B <= x"00000008";
    wait for cCLK_PER;
    -- expect o_Result = 0xFFDEADBE  (fill=1 because DEAD... is negative)

    -- Test 11d: SRA by 31  all bits become sign bit
    s_A <= x"FFFFFFFF"; s_B <= x"0000001F";
    wait for cCLK_PER;
    -- expect o_Result = 0xFFFFFFFF  (all ones, fill=1)

    -- Test 11e: SRA positive by 31  result = 0
    s_A <= x"7FFFFFFF"; s_B <= x"0000001F";
    wait for cCLK_PER;
    -- expect o_Result = 0x00000000  o_Zero = 1  (fill=0, 31 shifts)

    --=====================================================================
    -- GROUP 12: Zero flag cross-check
    --=====================================================================

    -- Test 12a: ADD producing zero
    s_ALUCtrl <= "0000";
    s_A <= x"00000005"; s_B <= x"FFFFFFFB";  -- 5 + (-5) = 0
    wait for cCLK_PER;
    -- expect o_Zero = 1

    -- Test 12b: AND producing zero
    s_ALUCtrl <= "0010";
    s_A <= x"AAAAAAAA"; s_B <= x"55555555";
    wait for cCLK_PER;
    -- expect o_Zero = 1

    -- Test 12c: SUB non-zero
    s_ALUCtrl <= "0001";
    s_A <= x"00000006"; s_B <= x"00000002";
    wait for cCLK_PER;
    -- expect o_Result = 0x00000004  o_Zero = 0

    wait;
  end process;

end behavior;