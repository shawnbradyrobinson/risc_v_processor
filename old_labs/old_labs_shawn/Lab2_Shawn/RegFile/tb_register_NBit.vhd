-------------------------------------------------------------------------
-- Shawn Robinson 
-------------------------------------------------------------------------


-- tb_register_NBit.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the N-bit register based on the provided 
-- dffg.vhd 
--
-- NOTES:
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_register_NBit is
  generic(gCLK_HPER   : time := 50 ns;
	  N	      : integer := 32); 
end tb_register_NBit;

architecture behavioral of tb_register_NBit is
  
  -- Calculate the clock period as twice the half-period
  constant cCLK_PER  : time := gCLK_HPER * 2;


  component register_NBit
    generic(N : integer := 32); 
    port(CLK        : in std_logic;     -- Clock input
         RST        : in std_logic;     -- Reset input
         WE         : in std_logic;     -- Write enable input
         D          : in std_logic_vector(N-1 downto 0);     -- Data value input
         Q          : out std_logic_vector(N-1 downto 0));   -- Data value output
  end component;

  -- Temporary signals to connect to the dff component.
  signal s_CLK		     : std_logic := '0';  
  signal s_RST		     : std_logic := '0'; 
  signal s_WE  		     : std_logic := '0';  
  signal s_D		     : std_logic_vector(N-1 downto 0) := x"00000000"; 
  signal s_Q 		     : std_logic_vector(N-1 downto 0);

begin

  DUT: register_NBit 
  generic map (N => N)
  port map(CLK => s_CLK, 
           RST => s_RST,
           WE  => s_WE,
           D   => s_D,
           Q   => s_Q);

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
  
  -- Testbench process  
  P_TB: process
  begin
    -- Reset the FF
    s_RST <= '1';
    s_WE  <= '0';
    s_D   <= (0 => '0', others => '0');
    wait for cCLK_PER;

    -- Store '1'
    s_RST <= '0';
    s_WE  <= '1';
    s_D   <= (0 => '1', others => '0');
    wait for cCLK_PER;  

    -- Keep '1'
    s_RST <= '0';
    s_WE  <= '0';
    s_D   <= (0 => '1', others => '0');
    wait for cCLK_PER;  

    -- Store '0'    
    s_RST <= '0';
    s_WE  <= '1';
    s_D   <= (0 => '0', others => '0');
    wait for cCLK_PER;  

    -- Keep '0'
    s_RST <= '0';
    s_WE  <= '0';
    s_D   <= (0 => '0', others => '0');
    wait for cCLK_PER;  

    wait;
  end process;
  
end behavioral;