-------------------------------------------------------------------------
-- Shawn Robinson 
-------------------------------------------------------------------------


-- fetch_unit.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: Fetch unit ready for implementation, with functioning PC Register 
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

--library work;
--use work.RISCV_types.all;

entity sw_fetch_unit is
  generic(N : integer := 32);
  port(iCLK               : in  std_logic;
       iRST               : in  std_logic;

       -- ── Mispredict recovery (from EX stage) ──────────────────────
       i_mispredict_target : in  std_logic_vector(31 downto 0);
       i_mispredict        : in  std_logic;   -- '1' = prediction was wrong

       -- ── Stall (from hazard unit) ──────────────────────────────────
       i_stall             : in  std_logic;

       -- ── BHT/BTB update (from EX stage) ───────────────────────────
       i_update_en         : in  std_logic;   -- '1' when branch/jump in EX
       i_update_PC         : in  std_logic_vector(31 downto 0);
       i_actual_taken      : in  std_logic;
       i_actual_target     : in  std_logic_vector(31 downto 0);

       -- ── Prediction output (to IFID register) ─────────────────────
       o_pred_taken        : out std_logic;

       -- ── Standard fetch outputs ────────────────────────────────────
       o_PC                : out std_logic_vector(31 downto 0);
       Pc_plus4            : out std_logic_vector(31 downto 0));
end  sw_fetch_unit;


architecture structure of sw_fetch_unit is

	constant c_immediate_four 	: std_logic_vector(31 downto 0) := x"00000004"; 
	constant c_PC_RESET 		: std_logic_vector(31 downto 0) := x"00400000";

	signal s_next_PC		: std_logic_vector(31 downto 0); 
	signal s_current_PC		: std_logic_vector(31 downto 0); 
	signal s_pc_plus4		: std_logic_vector(31 downto 0); 
	signal s_PC_WE			: std_logic;

	signal s_stall_inverted		: std_logic;

	-- ── Branch predictor internal signals ──────────────────────────
	signal s_raw_pred_taken		: std_logic;   -- BHT && BTB hit (unguarded)
	signal s_pred_target		: std_logic_vector(31 downto 0);
	-- Gate prediction: suppress during stalls and mispredict recovery
	signal s_pred_taken_gated	: std_logic;

  component branch_predictor is
    port(
      iCLK            : in  std_logic;
      iRST            : in  std_logic;
      i_pc_if         : in  std_logic_vector(31 downto 0);
      o_pred_taken    : out std_logic;
      o_pred_target   : out std_logic_vector(31 downto 0);
      i_update_en     : in  std_logic;
      i_pc_ex         : in  std_logic_vector(31 downto 0);
      i_actual_taken  : in  std_logic;
      i_actual_target : in  std_logic_vector(31 downto 0)
    );
  end component;

  component register_NBit is 
	generic(N: integer := 32); 
	port(D		: in std_logic_vector(N-1 downto 0); 
		RST	: in std_logic; 
		WE	: in std_logic; 
		CLK	: in std_logic; 
		Q	: out std_logic_vector(N-1 downto 0));
  end component;  		


  component andg2 is 
    port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);

  end component; 

  component invg is
	port(i_A          : in std_logic;
       		o_F          : out std_logic);

	end component;

  component pc_register is
  	port(	iCLK            	: in std_logic;
      		i_RST            	: in std_logic;
       		i_WE			: in std_logic;
       		i_D			: in std_logic_vector(31 downto 0); 
       		o_Q         		: out std_logic_vector(31 downto 0)); 
  end  component;


  component org2 is
    port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);

  end component; 

  
 component mux2t1_N is 
  generic(N : integer);
  port(i_S          : in std_logic;
       i_D0         : in std_logic_vector(N-1 downto 0);
       i_D1         : in std_logic_vector(N-1 downto 0);
       o_O          : out std_logic_vector(N-1 downto 0));

 end component;
 

  component carry_lookahead_adderN is
  generic(N : integer); 
  port(A         : in std_logic_vector(N-1 downto 0);
       B         : in std_logic_vector(N-1 downto 0);
       Cin       : in std_logic := '0';
       Sum	 : out std_logic_vector(N-1 downto 0);  
       Cout      : out std_logic); 

  end component;

begin
  o_PC 		<= s_current_PC; 
  PC_plus4	<= s_pc_plus4;

  -- ── PC write enable ──────────────────────────────────────────────
  -- Same as before: update on normal cycle (not stalled) or on mispredict
  -- recovery.  When not stalling, s_stall_inverted='1' so the NEXT_PC_MUX
  -- output (which may be a prediction target) is captured automatically.
  s_PC_WE <= s_stall_inverted or i_mispredict;

  -- ── Prediction gate: suppress during stall or mispredict recovery ─
  -- During a stall, the PC isn't advancing, so we must not act on the
  -- prediction for the currently-held instruction a second time.
  -- During a mispredict, the mispredict target takes absolute priority.
  s_pred_taken_gated <= s_raw_pred_taken and s_stall_inverted and (not i_mispredict);

  -- ── 3-way priority NEXT_PC selection ────────────────────────────
  --  Priority 1 (highest): mispredict recovery  → i_mispredict_target
  --  Priority 2           : BHT+BTB prediction  → s_pred_target
  --  Priority 3 (default) : sequential          → PC+4
  s_next_PC <= i_mispredict_target when i_mispredict = '1'
            else s_pred_target       when s_pred_taken_gated = '1'
            else s_pc_plus4;

  -- ── Prediction output to IFID register ───────────────────────────
  o_pred_taken <= s_pred_taken_gated;

   STALL_INV: invg
	port map(i_A	=> i_stall,
		 o_F	=> s_stall_inverted);

   PC4_ADD:	carry_lookahead_adderN
	generic map(N => 32)
	port map(A	=> s_current_PC,
		 B	=> c_immediate_four,
		 Cin 	=> '0',
		 Sum	=> s_pc_plus4,
		 Cout	=> open);

  -- ── Branch predictor instantiation ───────────────────────────────
  BP: branch_predictor
    port map(
      iCLK            => iCLK,
      iRST            => iRST,
      i_pc_if         => s_current_PC,
      o_pred_taken    => s_raw_pred_taken,
      o_pred_target   => s_pred_target,
      i_update_en     => i_update_en,
      i_pc_ex         => i_update_PC,
      i_actual_taken  => i_actual_taken,
      i_actual_target => i_actual_target
    );

 -- RESET_MUX:	mux2t1_N
	--generic map(N => 32)
	--port map(i_S	=> iRST,
	-- 	 i_D0	=> s_next_PC,
	-- 	 i_D1	=> x"00400000", -- reset value 
	-- 	 o_O	=> s_pc_reg_input);
--
   ---PC_REG: pc_register
   	--generic map(N => 32)
   --	port map(iCLK => iCLK,
	--	 i_RST => iRST,
	--	 i_WE  => '1',
	--	 i_D   => s_pc_reg_input,
	--	 o_Q	=> s_current_PC);

--RESET_MUX: mux2t1_N
  --  generic map(N => 32)
    --port map(i_S  => iRST,
      --       i_D0 => s_next_PC,
        --     i_D1 => x"00400000",
          --   o_O  => s_pc_reg_input);

PC_REG: pc_register
	port map(iCLK	=> iCLK,
		 i_RST	=> iRST,
		 i_WE	=> s_PC_WE, -- was s_stall_inverted -- shawn 
		 i_D	=> s_next_PC,
		 o_Q	=> s_current_PC);

end structure;
