-------------------------------------------------------------------------
-- Shawn Robinson 
-------------------------------------------------------------------------


-- fetch_unit.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: Fetch unit ready for implementation, with functioning PC Register 
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

--library work;
--use work.RISCV_types.all;

entity forwarding_unit is
  port( -- From ID/EX 
	EX_rs1_addr:		in std_logic_vector(4 downto 0);
	EX_rs2_addr:		in std_logic_vector(4 downto 0);
	
	-- From EX/MEM
	MEM_RegWrite:		in std_logic;
	MEM_rd_addr:		in std_logic_vector(4 downto 0);
	
	-- From MEM/WB 
	WB_RegWrite:		in std_logic; 
	WB_rd_addr:		in std_logic_vector(4 downto 0); 

	o_fwd_A:		out std_logic_vector(1 downto 0); -- associated with ALU A
	o_fwd_B:		out std_logic_vector(1 downto 0)
	); 
end  forwarding_unit;


architecture structural of forwarding_unit is
	
	signal s_MEM_match_rs1: 	std_logic; 
	signal s_MEM_match_rs2: 	std_logic; 
	signal s_WB_match_rs1: 		std_logic;
	signal s_WB_match_rs2:		std_logic; 
	signal S_MEM_nonzero:		std_logic; 
	signal s_WB_nonzero:		std_logic; 	
	

  


begin

    -- MEM stage rd != x0
    s_MEM_nonzero <= '1' when MEM_rd_addr /= "00000" else '0';

    -- WB stage rd != x0
    s_WB_nonzero  <= '1' when WB_rd_addr /= "00000" else '0';

    -- MEM stage matches
    s_MEM_match_rs1 <= '1' when (MEM_RegWrite = '1') and
                                (s_MEM_nonzero = '1') and
                                (MEM_rd_addr = EX_rs1_addr)
                       else '0';

    s_MEM_match_rs2 <= '1' when (MEM_RegWrite = '1') and
                                (s_MEM_nonzero = '1') and
                                (MEM_rd_addr = EX_rs2_addr)
                       else '0';

    -- WB stage matches
    s_WB_match_rs1  <= '1' when (WB_RegWrite = '1') and
                                (s_WB_nonzero = '1') and
                                (WB_rd_addr = EX_rs1_addr)
                       else '0';

    s_WB_match_rs2  <= '1' when (WB_RegWrite = '1') and
                                (s_WB_nonzero = '1') and
                                (WB_rd_addr = EX_rs2_addr)
                       else '0';

    -- Forward A select:
    -- MEM takes priority over WB (more recent value)
    o_fwd_A <= "01" when s_MEM_match_rs1 = '1' else
               "10" when s_WB_match_rs1  = '1' else
               "00";

    -- Forward B select:
    o_fwd_B <= "01" when s_MEM_match_rs2 = '1' else
               "10" when s_WB_match_rs2  = '1' else
               "00";

end structural;