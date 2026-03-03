-------------------------------------------------------------------------
-- Shawn Robinson 
-------------------------------------------------------------------------


-- adder_subtractorN.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide 
-- adder subtractor, where an add_sub select line set to 0 adds two values
-- and an add_sub select line set to 1 subtracts the two values 
--
-- NOTES:
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity adder_subtractorN is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 16.
  port(A         : in std_logic_vector(N-1 downto 0);
       B         : in std_logic_vector(N-1 downto 0);
       --don't need a Cin because the select handles it 
       add_sub_select : in std_logic;   
       Result	 : out std_logic_vector(N-1 downto 0); 
       Cout      : out std_logic); 

end adder_subtractorN;

architecture structural of adder_subtractorN is

  component ripple_carry_adderN is
    generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 16.
    port(A         : in std_logic_vector(N-1 downto 0);
         B         : in std_logic_vector(N-1 downto 0);
         Cin       : in std_logic;
         Sum	 : out std_logic_vector(N-1 downto 0);  
         Cout      : out std_logic); 
  end component;
  
  component ones_comp is
    generic(N: integer := 32);
    port(i_D0      : in std_logic_vector(N-1 downto 0);
         out_vec   : out std_logic_vector(N-1 downto 0)); 
  end component; 

  component mux2t1_N is 
    generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 16.
    port(i_S          : in std_logic;
         i_D0         : in std_logic_vector(N-1 downto 0);
         i_D1         : in std_logic_vector(N-1 downto 0);
         o_O          : out std_logic_vector(N-1 downto 0)); 
  end component; 

signal s_inverted_b : std_logic_vector(N-1 downto 0);  
signal selected_b   : std_logic_vector(N-1 downto 0); 


begin

---- LEVEL 0: SET B -------





inverter: ones_comp
  generic MAP(N => N)
  port    MAP(i_D0      => B,
	      out_vec   => s_inverted_b); 

add_sub_mux: mux2t1_N
  generic MAP(N => N)
  port    MAP(i_S 	=> add_sub_select,
	      i_D0	=> B, 
	      i_D1      => s_inverted_b,
	      o_O       => selected_b);  

 number_crunch: ripple_carry_adderN
  generic MAP(N => N)
  port    MAP(A		=> A,
	      B		=> selected_b,
	      Cin       => add_sub_select,
	      Sum       => Result,
	      Cout      => Cout); 



---------------------------


--- LEVEL 1: SET A --------


----------------------------


---- LEVEL 2: RESULTS ------ 




-----------------------------

end structural;