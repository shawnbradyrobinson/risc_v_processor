-------------------------------------------------------------------------
-- branch_predictor.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: Top-level branch predictor wrapper.
--   Instantiates a BHT (64 x 2-bit saturating counters) and a BTB
--   (16 entries, direct-mapped with tag).
--
-- Prediction is TAKEN only when BOTH conditions are true:
--   (1) BHT says taken  (counter MSB = '1')
--   (2) BTB has a valid matching entry  (hit = '1')
--
-- The BTB is only updated when the branch is actually taken, so it
-- always stores a real target address.  The BHT is updated on every
-- branch/jump resolution regardless of direction.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity branch_predictor is
  port(
    iCLK            : in  std_logic;
    iRST            : in  std_logic;

    
    i_pc_if         : in  std_logic_vector(31 downto 0);
    o_pred_taken    : out std_logic;
    o_pred_target   : out std_logic_vector(31 downto 0);

  
    -- i_update_en  : '1' when a branch OR jump instruction is in EX
    -- i_actual_taken: '1' if it was actually taken
    -- i_actual_target: the real resolved target address
    i_update_en     : in  std_logic;
    i_pc_ex         : in  std_logic_vector(31 downto 0);
    i_actual_taken  : in  std_logic;
    i_actual_target : in  std_logic_vector(31 downto 0)
  );
end branch_predictor;

architecture structure of branch_predictor is

  component bht is
    port(
      iCLK         : in  std_logic;
      iRST         : in  std_logic;
      i_pc_if      : in  std_logic_vector(31 downto 0);
      o_pred_taken : out std_logic;
      i_update_en  : in  std_logic;
      i_pc_ex      : in  std_logic_vector(31 downto 0);
      i_actual     : in  std_logic
    );
  end component;

  component btb is
    port(
      iCLK         : in  std_logic;
      iRST         : in  std_logic;
      i_pc_if      : in  std_logic_vector(31 downto 0);
      o_target     : out std_logic_vector(31 downto 0);
      o_hit        : out std_logic;
      i_update_en  : in  std_logic;
      i_pc_ex      : in  std_logic_vector(31 downto 0);
      i_target_ex  : in  std_logic_vector(31 downto 0)
    );
  end component;

  signal s_bht_pred   : std_logic;
  signal s_btb_hit    : std_logic;
  signal s_btb_target : std_logic_vector(31 downto 0);

begin

  -- ?? Combined prediction: need both BHT and BTB to agree ??????????
  o_pred_taken  <= s_bht_pred and s_btb_hit;
  o_pred_target <= s_btb_target;

  -- ?? BHT: updated on every branch/jump, regardless of direction ???
  BHT_INST: bht
    port map(
      iCLK         => iCLK,
      iRST         => iRST,
      i_pc_if      => i_pc_if,
      o_pred_taken => s_bht_pred,
      i_update_en  => i_update_en,
      i_pc_ex      => i_pc_ex,
      i_actual     => i_actual_taken
    );

  -- ?? BTB: only written when branch/jump is actually taken ?????????
  BTB_INST: btb
    port map(
      iCLK         => iCLK,
      iRST         => iRST,
      i_pc_if      => i_pc_if,
      o_target     => s_btb_target,
      o_hit        => s_btb_hit,
      i_update_en  => i_update_en and i_actual_taken,
      i_pc_ex      => i_pc_ex,
      i_target_ex  => i_actual_target
    );

end structure;
