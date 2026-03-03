library IEEE; 
use IEEE.std_logic_1164.all; 

package types_package is 

	type bus_32_t is array(31 downto 0) of std_logic_vector(31 downto 0); 
end package types_package; 