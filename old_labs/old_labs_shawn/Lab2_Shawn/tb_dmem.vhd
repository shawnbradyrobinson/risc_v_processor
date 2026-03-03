-------------------------------------------------------------------------
-- Shawn Robinson 
-------------------------------------------------------------------------


-- tb_dmem.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the
-- edge-triggered flip-flop with parallel access and reset.
--
--
-- NOTES:
-- 8/19/16 by JAZ::Design created.
-- 11/25/19 by H3:Changed name to avoid name conflict with Quartus
--          primitives.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_dmem is
  generic(gCLK_HPER   : time := 50 ns);
end tb_dmem;

architecture sim of tb_dmem is
  
  -- Calculate the clock period as twice the half-period
  constant cCLK_PER  : time := gCLK_HPER * 2;


  component mem
	generic(
		DATA_WIDTH : natural := 32; 
		ADDR_WIDTH : natural := 10

	);
    port(
		clk 	: in std_logic; 
		addr	: in std_logic_vector((ADDR_WIDTH-1) downto 0); 
		data	: in std_logic_vector((DATA_WIDTH-1) downto 0);
		we	: in std_logic;
		q	: out std_logic_vector((DATA_WIDTH-1) downto 0)
	);

  end component;

	signal s_CLK 	: std_logic := '0'; 
	signal s_ADDR 	: std_logic_vector(9 downto 0) 	:= (others => '0');
	signal S_DATA	: std_logic_vector(31 downto 0) := (others => '0');
	signal s_WE	: std_logic			:= '0';
	signal s_Q	: std_logic_vector(31 downto 0);


begin
	--NOTE TO SELF: THE "dmem" LABEL IS NOT ARBITRARY!!!!
  dmem: mem 
	generic map(
		DATA_WIDTH => 32,
		ADDR_WIDTH => 10
	)
	port map(
		clk 	=> s_CLK,
		addr	=> s_ADDR,
		data	=> s_DATA,
		we	=> s_WE,
		q	=> s_Q 
	);

  -- This process sets the clock value (low for gCLK_HPER, then high
  -- for gCLK_HPER). Absent a "wait" command, processes restart 
  -- at the beginning once they have reached the final statement.
  P_CLK: process
  begin
    s_CLK <= '0';
    wait for gCLK_HPER;
    s_CLK <= '1';
    wait for gCLK_HPER;
  end process;
  
  P_TB: process
    begin
        -- Initial State: Everything zeroed out
        s_WE   <= '0';
        s_ADDR <= (others => '0');
        s_DATA <= (others => '0');
        
        -- IMPORTANT: At this point in your lab, you would pause 
        -- or use the TCL command to load the .hex file.
        wait for cCLK_PER * 2;

        -----------------------------------------------------------
        -- PHASE (b): Read values from 0x0 to 0x2 (Example)
        -----------------------------------------------------------
        -- Read Address 0 (Value should be -1)
        s_ADDR <= "0000000000";
        wait for cCLK_PER; -- Observe s_Q in waveform

        -- Read Address 1 (Value should be 2)
        s_ADDR <= "0000000001";
        wait for cCLK_PER;

        -- Read Address 2 (Value should be -3)
        s_ADDR <= "0000000010";
        wait for cCLK_PER;

        -----------------------------------------------------------
        -- PHASE (c): Write those values to 0x100, 0x101, 0x102
        -----------------------------------------------------------
        -- Write -1 to Address 0x0100000000
        s_WE   <= '1';
        s_ADDR <= "0100000000"; 
        s_DATA <= x"FFFFFFFF"; -- -1
        wait for cCLK_PER;

        -- Write 2 to Address 0x0100000001
        s_ADDR <= "0100000001";
        s_DATA <= x"00000002"; -- 2
        wait for cCLK_PER;

        -- Write -3 to Address 0x102 (258 decimal)
        s_ADDR <= "0100000010";
        s_DATA <= x"FFFFFFFD"; -- -3
        wait for cCLK_PER;

        -----------------------------------------------------------
        -- PHASE (d): Verify the writes
        -----------------------------------------------------------
        s_WE   <= '0'; -- Disable writing so we can read
        
        -- Read Address 0x100....
        s_ADDR <= "0100000000";
        wait for cCLK_PER;

        -- Read Address 0x101
        s_ADDR <= "0100000001";
        wait for cCLK_PER;

        -- Read Address 0x102
        s_ADDR <= "0100000010";
        wait for cCLK_PER;

        -- End simulation
        wait;
    end process;

end sim;