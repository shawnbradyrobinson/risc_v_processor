-------------------------------------------------------------------------
-- bht.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: Branch History Table (BHT) with 64 entries of 2-bit
-- saturating counters.  Indexed by PC[7:2] (6 bits = 64 entries).
--
-- States:
--   "00" = Strongly Not-Taken  (predict NT)
--   "01" = Weakly   Not-Taken  (predict NT)
--   "10" = Weakly   Taken      (predict T)   <- reset/init value
--   "11" = Strongly Taken      (predict T)
--
-- Lookup is purely combinational (reads s_table in the same cycle).
-- Update is synchronous (writes on rising edge when i_update_en='1').
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity bht is
  port(
    iCLK         : in  std_logic;
    iRST         : in  std_logic;


    i_pc_if      : in  std_logic_vector(31 downto 0);
    o_pred_taken : out std_logic;          -- '1' when counter[1]='1'

    
    i_update_en  : in  std_logic;          -- '1' when branch/jump in EX
    i_pc_ex      : in  std_logic_vector(31 downto 0);
    i_actual     : in  std_logic           -- '1' = branch was taken
  );
end bht;

architecture behavioral of bht is

  type bht_table_t is array(0 to 63) of std_logic_vector(1 downto 0);
  signal s_table   : bht_table_t := (others => "10"); -- init: weakly taken

  signal s_rd_idx  : integer range 0 to 63;
  signal s_wr_idx  : integer range 0 to 63;

begin

 
  s_rd_idx <= to_integer(unsigned(i_pc_if(7 downto 2)));
  s_wr_idx <= to_integer(unsigned(i_pc_ex(7 downto 2)));


  o_pred_taken <= s_table(s_rd_idx)(1);


  process(iCLK)
    variable v_cnt : std_logic_vector(1 downto 0);
  begin
    if rising_edge(iCLK) then
      if iRST = '1' then
        s_table <= (others => "10");           -- reset to weakly taken
      elsif i_update_en = '1' then
        v_cnt := s_table(s_wr_idx);
        if i_actual = '1' then
          -- Increment toward Strongly Taken, saturate at "11"
          if v_cnt /= "11" then
            s_table(s_wr_idx) <= std_logic_vector(unsigned(v_cnt) + 1);
          end if;
        else
          -- Decrement toward Strongly Not-Taken, saturate at "00"
          if v_cnt /= "00" then
            s_table(s_wr_idx) <= std_logic_vector(unsigned(v_cnt) - 1);
          end if;
        end if;
      end if;
    end if;
  end process;

end behavioral;
