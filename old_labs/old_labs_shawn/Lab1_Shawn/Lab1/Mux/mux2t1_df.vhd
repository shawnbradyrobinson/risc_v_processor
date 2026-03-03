--------------------
-- Shawn Robinson 
-- 
-- 
--------------------


-- mux2t1.vhd 
---------------------------
-- DESCRIPTION: Implementation of a 2:1 mux for Lab 1 



-- NOTES: This version uses dataflow instead of structural formatting 
-------------------------------

library IEEE; 
use IEEE.std_logic_1164.all; 

entity mux2t1_df is 
Port( i_D0, i_D1, i_S : in std_logic; 
	o_O : out std_logic);

end mux2t1_df; 


architecture dataflow of mux2t1_df is 
signal s1, s0: std_logic; 



-- should I create intermediate signals here for the result of i_D1 AND i_S , as well as i_D0 AND ~i_S ? 
-- 


begin 
s1 <= i_D1 and i_S; 
s0 <= i_D0 and (not i_S); 
--rewriting this because the sim was optimizing away my DUT0? 
o_O <= s0 or s1; 

end dataflow; 