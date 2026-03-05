-------------------------------------------------------------------------
-- Shawn Robinson 
-------------------------------------------------------------------------


-- immediate_generator.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: generating the correct risc-v 32i immediate out, having been fed the full instruction 
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

--library work;
--use work.RISCV_types.all;

entity immediate_generator is
  port(
        instruction		: in  std_logic_vector(31 downto 0); 
        immediate_generate 	: out std_logic_vector(31 downto 0)
	); 
end  immediate_generator;


architecture dataflow of immediate_generator is

	signal s_opcode			: std_logic_vector(6 downto 0); 

	--set aside bit fields for each each instruction type -- 

	signal s_i_bits 		: std_logic_vector(11 downto 0); -- I-TYPE
	signal s_s_bits			: std_logic_vector(11 downto 0); -- S-TYPE
	signal s_b_bits			: std_logic_vector(11 downto 0); -- B-TYPE
	signal s_u_bits			: std_logic_vector(19 downto 0); -- U-TYPE
	signal s_j_bits			: std_logic_vector(19 downto 0); -- J-TYPE
	
	
	-- Intermediate extended signals
    	signal s_i_ext  : std_logic_vector(31 downto 0);
   	signal s_s_ext  : std_logic_vector(31 downto 0);
   	signal s_b_ext  : std_logic_vector(31 downto 0);
   	signal s_j_ext  : std_logic_vector(31 downto 0);
   	signal s_u_ext  : std_logic_vector(31 downto 0); -- LUI special formatting

	signal s_12_bits		: std_logic_vector(11 downto 0); 
	signal s_20_bits		: std_logic_vector(19 downto 0); 
	
	signal s_branch_and_zero	: std_logic; 
	


  component bitextender_12to32 is 
    port(imm12_in		: in std_logic_vector(11 downto 0);
	 sign_select		: in std_logic; -- 1 = sign extend, 0 = zero extend							
	 imm32_out		: out std_logic_vector(31 downto 0)
	);

  end component; 

 component bitextender_20to32 is 
   port(imm20_in		: in std_logic_vector(19 downto 0);
	sign_select		: in std_logic; 
	imm32_out		: out std_logic_vector(31 downto 0)); 
 end component; 






begin

  s_opcode <= instruction(6 downto 0); 
    -- I-Type: [31:20]
    s_i_bits <= instruction(31 downto 20);

    -- S-Type: [31:25] concatenated with [11:7]
    s_s_bits <= instruction(31 downto 25) & instruction(11 downto 7);

    -- B-Type: [31 | 7 | 30:25 | 11:8]
    s_b_bits <= instruction(31) & instruction(7) & instruction(30 downto 25) & instruction(11 downto 8);

    -- U-Type: [31:12]
    s_u_bits <= instruction(31 downto 12);

    -- J-Type: [31 | 19:12 | 20 | 30:21]
    s_j_bits <= instruction(31) & instruction(19 downto 12) & instruction(20) & instruction(30 downto 21);
  

   I_EXT: bitextender_12to32 
	port map(
			imm12_in	=> s_i_bits, 
			sign_select	=> '1',
			imm32_out	=> s_i_ext 
		); 
   S_EXT: bitextender_12to32
	port map(
			imm12_in	=> s_s_bits, 
			sign_select	=> '1',
			imm32_out	=> s_s_ext 
		); 
   B_EXT: bitextender_12to32
	port map(
			imm12_in	=> s_b_bits, 
			sign_select	=> '1',
			imm32_out	=> s_b_ext 
		); 
   J_EXT: bitextender_20to32
	port map(
			imm20_in	=> s_j_bits, 
			sign_select	=> '1',
			imm32_out	=> s_j_ext 
		); 
   --special u-type formatting for lui style -- 

   s_u_ext <= s_u_bits & x"000"; 

   with s_opcode select
	immediate_generate <= s_i_ext when "0010011", -- ADDI 
			      s_i_ext when "0000011", -- LW
			      s_i_ext when "1100111", -- JALR
			      s_s_ext when "0100011", -- SW
		              s_b_ext when "1100011", -- BEQ/BNE
			      s_u_ext when "0110111", -- LUI
			      s_u_ext when "0010111", -- AUIPC
			      s_j_ext when "1101111", -- JAL
			      
			      x"00000000" when others; 

end dataflow;