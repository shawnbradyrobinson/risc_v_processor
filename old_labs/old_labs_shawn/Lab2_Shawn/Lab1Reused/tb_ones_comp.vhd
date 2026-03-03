-------------------------------------------------------------------------
-- Shawn Robinson 
-------------------------------------------------------------------------
-- tb_ones_comp.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for my one's complementer implementation 
--              

-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use std.env.all;                -- For hierarchical/external signals
use std.textio.all;             -- For basic I/O

-- Usually name your testbench similar to below for clarity tb_<name>

entity tb_ones_comp is
  --  generic(gCLK_HPER   : time := 10 ns;
  --        DATA_WIDTH  : integer := 8);   -- Generic for half of the clock cycle period



end tb_ones_comp;

architecture mixed of tb_ones_comp is
constant N : integer := 32; 
-- Define the total clock period time
-- constant cCLK_PER  : time := gCLK_HPER * 2;

-- We will be instantiating our design under test (DUT), so we need to specify its
-- component interface.
-- TODO: change component declaration as needed.
component ones_comp is
  generic(N: integer := 32);
  port(i_D0      : in std_logic_vector(N-1 downto 0);
       out_vec   : out std_logic_vector(N-1 downto 0)); 
end component;

-- Create signals for all of the inputs and outputs of the file that you are testing
-- := '0' or := (others => '0') just make all the signals start at an initial value of zero
--signal CLK, reset : std_logic := '0';

-- TODO: change input and output signals as needed.
signal s_i_D0   : std_logic_vector(N-1 downto 0) := x"00000000";
signal s_out_vec   : std_logic_vector(N-1 downto 0);

begin

  -- TODO: Actually instantiate the component to test and wire all signals to the corresponding
  -- input or output. Note that DUT0 is just the name of the instance that can be seen 
  -- during simulation. What follows DUT0 is the entity name that will be used to find
  -- the appropriate library component during simulation loading.
  DUT0: ones_comp
  generic map (N => N)
  port map(
            i_D0           => s_i_D0,
            out_vec        => s_out_vec);
  --You can also do the above port map in one line using the below format: http://www.ics.uci.edu/~jmoorkan/vhdlref/compinst.html

  
  --This first process is to setup the clock for the test bench
  --P_CLK: process
  --begin
  --  CLK <= '1';         -- clock starts at 1
--    wait for gCLK_HPER; -- after half a cycle
--    CLK <= '0';         -- clock becomes a 0 (negative edge)
--    wait for gCLK_HPER; -- after half a cycle, process begins evaluation again
  --end process;

  -- This process resets the sequential components of the design.
  -- It is held to be 1 across both the negative and positive edges of the clock
  -- so it works regardless of whether the design uses synchronous (pos or neg edge)
  -- or asynchronous resets.
--  P_RST: process
--  begin
  --	reset <= '0';   
  --  wait for gCLK_HPER/2;
	--reset <= '1';
  --  wait for gCLK_HPER*2;
	--reset <= '0';
	--wait;
  --end process;  
  
  -- Assign inputs for each test case.
  -- TODO: add test cases as needed.
  P_TEST_CASES: process
  begin
    --wait for gCLK_HPER/2; -- for waveform clarity, I prefer not to change inputs on clk edges

    -- Test case 1:
    -- Initialize weight value to 10.
    s_i_D0   <= x"00000000";  
   
    wait for 100 ns; 
    -- Expect: out_vec should be all F's 

    -- Test case 2:
    -- Perform average example of an input activation of 3 and a partial sum of 25. The weight is still 10. 
    s_i_D0   <= x"FFFFFFFF";  
   
    wait for 100 ns; 
    -- Expect: out_vec should be all zeroes


   -- Test case 3:
   -- Sum up to 7 (the day I was born, and also the month for what it's worth)  
   s_i_D0 <= x"AAAAAAAA"; 

   wait for 100 ns; 	
   -- Expect: out_vec should be all 5's 

   wait;
  end process;

end mixed;