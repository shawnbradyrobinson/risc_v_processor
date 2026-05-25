-------------------------------------------------------------------------
-- IFID_PipelineRegister.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: IF/ID Pipeline Register for RISC-V 5-stage pipeline.
-- Latches PC and full instruction from the IF stage.
-- Field slicing (opcode, rs1, rs2, rd, funct3) should be done
-- combinationally in the parent architecture, not here.
-------------------------------------------------------------------------

library IEEE; 
use IEEE.std_logic_1164.all; 

entity IFID_PipelineRegister is 

port(	iCLK: 		in std_logic;
	iRST: 		in std_logic;
	iWE:		in std_logic;  -- for stall control?
	iFLUSH:		in std_logic; 

	--IF INPUTS 
	IF_PC:	  	in std_logic_vector(31 downto 0); 
	IF_Instr: 	in std_logic_vector(31 downto 0); 
	IF_PC_Plus4:	in std_logic_vector(31 downto 0);

	--ID OUTPUTS
	ID_PC:		out std_logic_vector(31 downto 0); 
	ID_Instr: 	out std_logic_vector(31 downto 0);
	ID_PC_Plus4:	out std_logic_vector(31 downto 0)
); 

end IFID_PipelineRegister;

architecture structural of IFID_PipelineRegister is 

	component register_NBit is
    		generic(N : integer := 32);
    		port(	D   : in  std_logic_vector(N-1 downto 0);
         		RST : in  std_logic;
         		WE  : in  std_logic;
         		CLK : in  std_logic;
         		Q   : out std_logic_vector(N-1 downto 0));
  	end component;


	component mux2t1_N is
    		generic(N : integer := 32);
    		port(i_S  : in std_logic;
        		 i_D0 : in std_logic_vector(N-1 downto 0);
        	 	i_D1 : in std_logic_vector(N-1 downto 0);
         		o_O  : out std_logic_vector(N-1 downto 0));
	end component;

	-- Insert flush-gated inputs here eventually? 
	signal s_PC_in		: std_logic_vector(31 downto 0);
	signal s_Instr_in 	: std_logic_vector(31 downto 0);
	signal s_PC4_in		: std_logic_vector(31 downto 0);
	signal s_WE_gated	: std_logic; 


begin 
  --FOR FUTURE REFERENCE ON FLUSHING/SQUASHING
  -- On flush, force NOP (ADDI x0, x0, 0 = 0x00000013) into the
  -- instruction slot and zero the PC rather than latching bad values
  --s_PC_in    <= (others => '0')      when iFLUSH = '1' else IF_PC;
  --s_Instr_in <= x"00000013"          when iFLUSH = '1' else IF_Instr;
	s_WE_gated <= iWE or iFLUSH;
	MUX_PC: mux2t1_N
		generic map(N => 32)
		port map(i_S	=> iFLUSH,
			 i_D0	=> IF_PC,
			 i_D1	=> (others => '0'), -- nop!
			 o_O	=> s_PC_in);


	MUX_Instr: mux2t1_N
		generic map(N => 32)
		port map(i_S	=> iFLUSH,
			 i_D0	=> IF_Instr,
			 i_D1	=> x"00000013", -- nop!
			 o_O	=> s_Instr_in);
 	MUX_PC4: mux2t1_N
		generic map(N => 32)
		port map(i_S	=> iFLUSH,
			 i_D0	=> IF_PC_Plus4,
			 i_D1	=> (others => '0'),
			 o_O	=> s_PC4_in);


	REG_PC: register_NBit
		generic map(N => 32)
		port map(
			D 	=> s_PC_in,
			RST 	=> iRST,
			WE	=> s_WE_gated,
			CLK 	=> iCLK,
			Q 	=> ID_PC
		);

	REG_Instr: register_NBit
		generic map(N => 32)
		port map(
			D 	=> s_Instr_in,
			WE	=> s_WE_gated,
			RST	=> iRST,
			CLK 	=> iCLK,
			Q	=> ID_Instr
		);

	REG_PC_Plus4: register_NBit
    		generic map(N => 32)
    		port map(
        		D   => s_PC4_in,
        		RST => iRST,
       			WE  => s_WE_gated,
        		CLK => iCLK,
        		Q   => ID_PC_Plus4
		);



	
end structural; 





