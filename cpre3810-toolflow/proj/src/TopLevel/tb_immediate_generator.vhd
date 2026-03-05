library IEEE;
use IEEE.std_logic_1164.all;

entity tb_immediate_generator is
end tb_immediate_generator;

architecture behavior of tb_immediate_generator is

    -- Component Declaration
    component immediate_generator
        port(
            instruction        : in std_logic_vector(31 downto 0);
            immediate_generate : out std_logic_vector(31 downto 0)
        );
    end component;

    -- Signals
    signal s_instruction : std_logic_vector(31 downto 0) := (others => '0');
    signal s_imm_out     : std_logic_vector(31 downto 0);

begin

    -- Instantiate the Unit Under Test (UUT)
    DUT: immediate_generator
    port map (
        instruction        => s_instruction,
        immediate_generate => s_imm_out
    );

    -- Stimulus process
    stim_proc: process
    begin		
        -- Wait for initial state
        wait for 10 ns;

        -----------------------------------------------------------
        -- TEST 1: I-Type (ADDI x1, x2, 5)
        -- Binary: [ Imm: 000000000101 | rs1: 00010 | f3: 000 | rd: 00001 | op: 0010011 ]
        -----------------------------------------------------------
        s_instruction <= x"00510093"; 
        wait for 10 ns;
        -- Expected s_imm_out: 0x00000005

        -----------------------------------------------------------
        -- TEST 2: S-Type (SW x5, 8(x10))
        -- Imm[11:5] = 0000000, Imm[4:0] = 01000 (8 decimal)
        -----------------------------------------------------------
        s_instruction <= x"00552423"; 
        wait for 10 ns;
        -- Expected s_imm_out: 0x00000008

        -----------------------------------------------------------
        -- TEST 3: B-Type (BEQ x1, x2, -4)
        -- Imm = -4 (0xFFFFFFFC). Encoded bits will be shuffled.
        -----------------------------------------------------------
        s_instruction <= x"fe208ee3"; 
        wait for 10 ns;
        -- Expected s_imm_out: 0xfffffffc (-4)

        -----------------------------------------------------------
        -- TEST 4: U-Type (LUI x1, 0x12345)
        -----------------------------------------------------------
        s_instruction <= x"123450b7"; 
        wait for 10 ns;
        -- Expected s_imm_out: 0x12345000

        -----------------------------------------------------------
        -- TEST 5: J-Type (JAL x1, 2000)
        -----------------------------------------------------------
        s_instruction <= x"7d0000ef"; 
        wait for 10 ns;
        -- Expected s_imm_out: 0x000007d0 (2000 decimal)

        wait;
    end process;

end behavior;