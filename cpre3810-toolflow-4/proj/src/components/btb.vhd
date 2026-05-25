-------------------------------------------------------------------------
-- btb.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: Branch Target Buffer (BTB) ? 16-entry direct-mapped.
--
-- Index : PC[5:2]  (4 bits ? 16 rows)
-- Tag   : PC[31:6] (26 bits ? disambiguates aliasing entries)
-- Entry : valid(1) + tag(26) + target(32)
--
-- A lookup is a HIT only when valid='1' AND tag matches.
-- The BTB is written ONLY when a branch/jump is actually taken,
-- keeping the table filled with useful targets.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity btb is
  port(
    iCLK         : in  std_logic;
    iRST         : in  std_logic;

  
    i_pc_if      : in  std_logic_vector(31 downto 0);
    o_target     : out std_logic_vector(31 downto 0); -- predicted target
    o_hit        : out std_logic;                      -- '1' = valid hit

    
    i_update_en  : in  std_logic;          -- '1' = write this entry
    i_pc_ex      : in  std_logic_vector(31 downto 0);
    i_target_ex  : in  std_logic_vector(31 downto 0)  -- actual target
  );
end btb;

architecture behavioral of btb is

  type target_table_t is array(0 to 15) of std_logic_vector(31 downto 0);
  type tag_table_t    is array(0 to 15) of std_logic_vector(25 downto 0);
  type valid_table_t  is array(0 to 15) of std_logic;

  signal s_targets : target_table_t := (others => (others => '0'));
  signal s_tags    : tag_table_t    := (others => (others => '0'));
  signal s_valid   : valid_table_t  := (others => '0');

  signal s_rd_idx  : integer range 0 to 15;
  signal s_wr_idx  : integer range 0 to 15;

begin

 
  s_rd_idx <= to_integer(unsigned(i_pc_if(5 downto 2)));
  s_wr_idx <= to_integer(unsigned(i_pc_ex(5 downto 2)));

 
  o_target <= s_targets(s_rd_idx);

  -- Hit: valid bit set AND upper PC tag matches
  o_hit <= '1' when (s_valid(s_rd_idx) = '1' and
                     s_tags(s_rd_idx)  = i_pc_if(31 downto 6))
           else '0';


  process(iCLK)
  begin
    if rising_edge(iCLK) then
      if iRST = '1' then
        s_valid   <= (others => '0');
        s_tags    <= (others => (others => '0'));
        s_targets <= (others => (others => '0'));
      elsif i_update_en = '1' then
        s_valid(s_wr_idx)   <= '1';
        s_tags(s_wr_idx)    <= i_pc_ex(31 downto 6);
        s_targets(s_wr_idx) <= i_target_ex;
      end if;
    end if;
  end process;

end behavioral;
