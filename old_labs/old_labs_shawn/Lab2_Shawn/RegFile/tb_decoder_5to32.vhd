-------------------------------------------------------------------------
-- Shawn Robinson 
-------------------------------------------------------------------------


-- tb_decoder5to32.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for my 5 to 32 decoder 
--
-- NOTES:
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_decoder_5to32 is
  
end tb_decoder_5to32;

architecture behavioral of tb_decoder_5to32 is
  
  -- Calculate the clock period as twice the half-period
 -- constant cCLK_PER  : time := gCLK_HPER * 2;


  component decoder_5to32
    port(input_address           : in std_logic_vector(4 downto 0);  
         enabled_line_out        : out std_logic_vector(31 downto 0)
         );  
  end component;

  -- Temporary signals to connect to the dff component.
  signal s_input_address		     : std_logic_vector(4 downto 0) := "00000";  
  signal s_enabled_line_out		     : std_logic_vector(31 downto 0);

begin

  DUT: decoder_5to32 
  port map(input_address => s_input_address, 
           enabled_line_out => s_enabled_line_out);

  -- This process sets the clock value (low for gCLK_HPER, then high
  -- for gCLK_HPER). Absent a "wait" command, processes restart 
  -- at the beginning once they have reached the final statement.
--  P_CLK: process
--  begin
 --   s_CLK <= '0';
 --   wait for gCLK_HPER;
 --   s_CLK <= '1';
--    wait for gCLK_HPER;
--  end process;
  
  -- Testbench process  
  P_TB: process
  begin
    -- Reset the FF
  --  s_RST <= '1';
  --  s_WE  <= '0';
 --   s_D   <= (0 => '0', others => '0');
   -- wait for 100 ns;

    -- Access 'RISC-V temp register 1...t1 = x5'
    s_input_address   <= "00101";
    wait for 100 ns; 
    -- Expect enabled_line_out to be "00000000000000000000000000100000" -- 00000020 in hex


    -- Access 'RISC-V saved register 1...s0 = x8'
    s_input_address   <= "01000";
    wait for 100 ns; 
    -- Expect enabled_line_out to be "0000_0000_0000_0000_0000_0001_0000_0000" -- 00000100 in hex 

    -- Access 'RISC-V argument register 1...t0 = x10'
    s_input_address   <= "01010";
    wait for 100 ns; 
    -- Expect enabled_line_out to be "0000_0000_0000_0000_0000_0100_0000_0000" -- 00000400 in hex 

    -- Access 'RISC-V return address register...ra = x1'
    s_input_address   <= "00001";
    wait for 100 ns; 
    -- Expect enabled_line_out to be "00000000000000000000000000000001" -- 00000002 in hex 

    wait;
  end process;
  
end behavioral;