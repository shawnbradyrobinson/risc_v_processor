-------------------------------------------------------------------------
-- Shawn Robinson 
-------------------------------------------------------------------------
-- tb_ripple_carry_adderN.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for my NBit ripple carry adder
--              

-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use std.env.all;                -- For hierarchical/external signals
use std.textio.all;             -- For basic I/O

-- Usually name your testbench similar to below for clarity tb_<name>

entity tb_ripple_carry_adderN is
  --  generic(gCLK_HPER   : time := 10 ns;
  --        DATA_WIDTH  : integer := 8);   -- Generic for half of the clock cycle period



end tb_ripple_carry_adderN;

architecture mixed of tb_ripple_carry_adderN is
constant N : integer := 32; 
-- Define the total clock period time
-- constant cCLK_PER  : time := gCLK_HPER * 2;

-- We will be instantiating our design under test (DUT), so we need to specify its
-- component interface.
-- TODO: change component declaration as needed.
component ripple_carry_adderN is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(A         : in std_logic_vector(N-1 downto 0);
       B         : in std_logic_vector(N-1 downto 0);
       Cin       : in std_logic;
       Sum	 : out std_logic_vector(N-1 downto 0);  
       Cout      : out std_logic); 

end component;

-- Create signals for all of the inputs and outputs of the file that you are testing
-- := '0' or := (others => '0') just make all the signals start at an initial value of zero
--signal CLK, reset : std_logic := '0';

-- TODO: change input and output signals as needed.
signal s_A   	: std_logic_vector(N-1 downto 0) := x"00000000";
signal s_B   	: std_logic_vector(N-1 downto 0) := x"00000000"; 
signal s_Cin 	: std_logic := '0';
signal s_Cout	: std_logic; 
signal s_Sum    : std_logic_vector(N-1 downto 0);

begin

  -- TODO: Actually instantiate the component to test and wire all signals to the corresponding
  -- input or output. Note that DUT0 is just the name of the instance that can be seen 
  -- during simulation. What follows DUT0 is the entity name that will be used to find
  -- the appropriate library component during simulation loading.
  DUT0: ripple_carry_adderN
  generic map (N => N)
  port map(
            A           => s_A,
	    B		=> s_B,
	    Cin 	=> s_Cin,
	    Cout	=> s_Cout,
            Sum         =>  s_Sum);

 
  
  -- Assign inputs for each test case.
  -- TODO: add test cases as needed.
  P_TEST_CASES: process
  begin
    --wait for gCLK_HPER/2; -- for waveform clarity, I prefer not to change inputs on clk edges

    -- Test case 1:
    s_A   <= x"000000FF";  
    s_B	  <= x"00000000"; 
    s_Cin <= '0'; 

    wait for 100 ns; 
    -- Expect: Sum to be 000000FF and Cout to be zero 

 -- Test case 2:
    s_A   <= x"FFFFFFFF";  
    s_B	  <= x"FFFFFFFF"; 
    s_Cin <= '0'; 

    wait for 100 ns; 
    -- Expect: Sum to be FFFFFFFE and Cout to be one 


 -- Test case 3:
    s_A   <= x"AAAAAAAA";  
    s_B	  <= x"00000001"; 
    s_Cin <= '0'; 

    wait for 100 ns; 
    -- Expect: Sum to be AAAAAAAB and Cout to be 0

   wait;
  end process;

end mixed;