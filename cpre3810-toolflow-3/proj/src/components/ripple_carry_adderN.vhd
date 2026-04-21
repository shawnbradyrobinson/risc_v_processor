-------------------------------------------------------------------------
-- Shawn Robinson 
-------------------------------------------------------------------------


-- ripple_carry_adderN.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide 
-- ripple carry adder 
--
-- NOTES:
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity ripple_carry_adderN is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 16.
  port(A         : in std_logic_vector(N-1 downto 0);
       B         : in std_logic_vector(N-1 downto 0);
       Cin       : in std_logic;
       Sum	 : out std_logic_vector(N-1 downto 0);  
       Cout      : out std_logic); 

end ripple_carry_adderN;

architecture structural of ripple_carry_adderN is

  component full_adder is
    port(A                 : in std_logic;
         B                 : in std_logic;
         Cin               : in std_logic;
         Sum               : out std_logic;
	 Cout		   : out std_logic);
  end component;

  signal s_carry : std_logic_vector(N downto 0); 

begin

  -- Instantiate N full_adder instances.
  s_carry(0) <= Cin; 
  G_NBit_ADDS: for i in 0 to N-1 generate
    ADDERS: full_adder port map(
              A     => A(i),      
              B     => B(i),  
              Cin   => s_carry(i),  
              Sum   => Sum(i),
	      Cout  => s_carry(i+1));  -- ith instance's data output hooked up to ith data output.
  end generate G_NBit_ADDS;

 -- have to handle the final carry out 
Cout <= s_carry(N);
  
end structural;