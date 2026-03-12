library IEEE;
use IEEE.std_logic_1164.all;

entity tb_fetch_unit_sandbox is
  generic(gCLK_HPER : time := 50 ns);
end tb_fetch_unit_sandbox;

architecture behavioral of tb_fetch_unit_sandbox is
  
  constant cCLK_PER : time := gCLK_HPER * 2;
  constant N : integer := 32;

  -- Component Declaration
  component fetch_unit_sandbox
    generic(N : integer := 32);
    port(
      iCLK               : in std_logic;
      iRST               : in std_logic;
      PC                 : in std_logic_vector(31 downto 0);
      rs1                : in std_logic_vector(31 downto 0); 
      PC_SRC             : in std_logic; 
      JUMP               : in std_logic; 
      BRANCH             : in std_logic; 
      ZERO               : in std_logic; 
      immediate_generate : in std_logic_vector(31 downto 0);
      s_PC               : out std_logic_vector(31 downto 0)
    );
  end component;

  -- Signals [cite: 8-18]
  signal s_iCLK               : std_logic := '0';
  signal s_iRST               : std_logic := '0';
  signal s_PC                 : std_logic_vector(31 downto 0) := x"00001000";
  signal s_rs1                : std_logic_vector(31 downto 0) := (others => '0');
  signal s_PC_SRC             : std_logic := '0';
  signal s_JUMP               : std_logic := '0';
  signal s_BRANCH             : std_logic := '0';
  signal s_ZERO               : std_logic := '0';
  signal s_imm_gen            : std_logic_vector(31 downto 0) := (others => '0');
  signal s_next_PC            : std_logic_vector(31 downto 0);

begin

  -- Instantiate the Design Under Test (DUT) [cite: 20]
  DUT: fetch_unit_sandbox
    generic map(N => N)
    port map(
      iCLK               => s_iCLK,
      iRST               => s_iRST,
      PC                 => s_PC,
      rs1                => s_rs1,
      PC_SRC             => s_PC_SRC,
      JUMP               => s_JUMP,
      BRANCH             => s_BRANCH,
      ZERO               => s_ZERO,
      immediate_generate => s_imm_gen,
      s_PC               => s_next_PC
    );

  -- Clock Process [cite: 21, 22]
  P_CLK: process
  begin
    s_iCLK <= '0';
    wait for gCLK_HPER;
    s_iCLK <= '1';
    wait for gCLK_HPER;
  end process;

  -- Test Process
  P_TB: process
  begin
    -- RESET [cite: 23-25]
    s_iRST <= '1';
    wait for cCLK_PER * 2;
    s_iRST <= '0';
    wait for cCLK_PER;

    -------------------------------------------------------
    -- Case #1: Normal PC + 4 (Standard Step)
    -------------------------------------------------------
    wait until falling_edge(s_iCLK);
    s_PC       <= x"00001000";
    s_PC_SRC   <= '0'; -- Select PC
    s_JUMP     <= '0';
    s_BRANCH   <= '0';
    s_ZERO     <= '0';
    -- Result should be 0x1004
    
    -------------------------------------------------------
    -- Case #2: Branch Taken (PC + Imm)
    -------------------------------------------------------
    wait until falling_edge(s_iCLK);
    s_PC       <= x"00001004";
    s_imm_gen  <= x"00000010"; -- Branch offset of 16
    s_BRANCH   <= '1';
    s_ZERO     <= '1'; -- Branch condition met
    -- Result should be 0x1004 + 0x10 = 0x1014
    
    -------------------------------------------------------
    -- Case #3: Branch Not Taken (Still PC + 4)
    -------------------------------------------------------
    wait until falling_edge(s_iCLK);
    s_PC       <= x"00001004";
    s_BRANCH   <= '1';
    s_ZERO     <= '0'; -- Condition NOT met
    -- Result should revert to PC + 4 = 0x1008
    
    -------------------------------------------------------
    -- Case #4: JALR (rs1 + Imm)
    -------------------------------------------------------
    wait until falling_edge(s_iCLK);
    s_PC_SRC   <= '1'; -- Select rs1 as base
    s_rs1      <= x"00002000";
    s_imm_gen  <= x"00000008";
    s_JUMP     <= '1'; -- Jump overrides +4 logic
    -- Result should be 0x2000 + 0x8 = 0x2008

    -------------------------------------------------------
    -- Cleanup
    -------------------------------------------------------
    wait until falling_edge(s_iCLK);
    s_JUMP   <= '0';
    s_BRANCH <= '0';
    wait for cCLK_PER * 2;
    wait;
  end process;

end behavioral;