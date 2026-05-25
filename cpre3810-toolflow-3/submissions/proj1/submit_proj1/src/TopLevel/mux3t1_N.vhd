-------------------------------------------------------------------------
-- mux3t1_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: N-bit wide 3:1 mux built from two mux2t1_N instances.
-- Select encoding:
--   "00" -> i_D0
--   "01" -> i_D1
--   "10" -> i_D2
--   "11" -> i_D2 (default, same as "10")
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity mux3t1_N is
    generic(N : integer := 32);
    port(i_S  : in  std_logic_vector(1 downto 0);
         i_D0 : in  std_logic_vector(N-1 downto 0);
         i_D1 : in  std_logic_vector(N-1 downto 0);
         i_D2 : in  std_logic_vector(N-1 downto 0);
         o_O  : out std_logic_vector(N-1 downto 0));
end mux3t1_N;

architecture structural of mux3t1_N is

    component mux2t1_N is
        generic(N : integer := 32);
        port(i_S  : in  std_logic;
             i_D0 : in  std_logic_vector(N-1 downto 0);
             i_D1 : in  std_logic_vector(N-1 downto 0);
             o_O  : out std_logic_vector(N-1 downto 0));
    end component;

    -- intermediate signal between the two mux stages
    signal s_first_mux_out : std_logic_vector(N-1 downto 0);

begin

    -- First mux: select between D0 and D1 using bit 0 of select
    MUX_01: mux2t1_N
        generic map(N => N)
        port map(i_S  => i_S(0),
                 i_D0 => i_D0,
                 i_D1 => i_D1,
                 o_O  => s_first_mux_out);

    -- Second mux: select between first mux output and D2 using bit 1 of select
    MUX_012: mux2t1_N
        generic map(N => N)
        port map(i_S  => i_S(1),
                 i_D0 => s_first_mux_out,
                 i_D1 => i_D2,
                 o_O  => o_O);

end structural;