-------------------------------------------------------------------------
-- hazard_detection_unit.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: full hazard detection unit for five stage pipeline hardware design 
-------------------------------------------------------------------------

library IEEE; 
use IEEE.std_logic_1164.all; 

entity hazard_detection_unit is 
	port(
		
		MEM_RegWrite	: in std_logic; -- mem stage hazard 
		MEM_rd_addr	: in std_logic_vector(4 downto 0); -- mem stage hazard
		EX_RegWrite	: in std_logic; -- any reg-write in ex hazard 
		EX_MemRead	: in std_logic; -- load use hazard
		EX_rd_addr	: in std_logic_vector(4 downto 0); -- load use hazard 
		ID_rs1_addr	: in std_logic_vector(4 downto 0); -- consumer instruction in ID
		ID_rs2_addr	: in std_logic_vector(4 downto 0); -- consumer instruction in ID
		o_stall		: out std_logic
	); 

end hazard_detection_unit;

architecture structural of hazard_detection_unit is 

    component andg2 is
        port(i_A : in std_logic;
             i_B : in std_logic;
             o_F : out std_logic);
    end component;

    component org2 is
        port(i_A : in std_logic;
             i_B : in std_logic;
             o_F : out std_logic);
    end component;

  	signal s_rs1_match	: std_logic; 
 	signal s_rs2_match	: std_logic;
	signal s_rd_nonzero	: std_logic;
	signal s_rs1_or_rs2	: std_logic;
	signal s_match_nonzero	: std_logic;           



	signal s_load_use_hazard	: std_logic;
	signal s_EX_RAW_hazard		: std_logic; 
	signal s_MEM_RAW_hazard		: std_logic; 
	signal s_EX_or_load		: std_logic; 

begin 

 -- ====== LOAD-USE HAZARD ======
    -- load in EX, consumer in ID
    s_load_use_hazard <= '1' when (EX_MemRead = '1') and
                                  (EX_rd_addr /= "00000") and
                                  (EX_rd_addr = ID_rs1_addr or
                                   EX_rd_addr = ID_rs2_addr)
                         else '0';

    -- ====== EX STAGE RAW HAZARD ======
    -- any register-writing instruction in EX, consumer in ID -- will be deleted with forwarding!
    s_EX_RAW_hazard  <= '1' when (EX_RegWrite = '1') and
                                  (EX_rd_addr /= "00000") and
                                  (EX_rd_addr = ID_rs1_addr or
                                   EX_rd_addr = ID_rs2_addr)
                         else '0';

    -- ====== MEM STAGE RAW HAZARD ======
    -- register-writing instruction in MEM, consumer in ID -- also will be deleted with forwarding!
    s_MEM_RAW_hazard <= '1' when (MEM_RegWrite = '1') and
                                  (MEM_rd_addr /= "00000") and
                                  (MEM_rd_addr = ID_rs1_addr or
                                   MEM_rd_addr = ID_rs2_addr)
                         else '0';

    -- ====== COMBINE ALL HAZARDS ======
    EX_OR_LOAD: org2
        port map(i_A => s_load_use_hazard,
                 i_B => s_EX_RAW_hazard,
                 o_F => s_EX_or_load);

    STALL_OUT: org2
        port map(i_A => s_EX_or_load,
                 i_B => s_MEM_RAW_hazard,
                 o_F => o_stall);

end structural;

