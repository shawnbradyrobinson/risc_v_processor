-- Practice VHDL file by Jay Patel
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity practice is
    port(
        a : in  STD_LOGIC;
        b : in  STD_LOGIC;
        y : out STD_LOGIC
    );
end practice;

architecture behavioral of practice is
begin
    y <= a AND b;  -- simple AND gate
end behavioral;