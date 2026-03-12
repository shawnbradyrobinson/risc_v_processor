-------------------------------------------------------------------------
-- Shawn Robinson 
-------------------------------------------------------------------------
--NEW COMMENT NEW COMMENT

-- fetch_unit_sandbox.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: Testing out some fetch unit ideas in isolation before it gets fully implemented into the processor 
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

--library work;
--use work.RISCV_types.all;

entity fetch_unit_sandbox is
  generic(N : integer := 32);
  port(iCLK            		: in std_logic;
       iRST            		: in std_logic;
       PC	       		: in std_logic_vector(31 downto 0);
       rs1			: in std_logic_vector(31 downto 0); 
       PC_SRC			: in std_logic; 
       JUMP			: in std_logic; 
       BRANCH			: in std_logic; 
       ZERO			: in std_logic; 
       immediate_generate 	: in std_logic_vector(31 downto 0);
       s_PC         		: out std_logic_vector(31 downto 0)); 
end  fetch_unit_sandbox;


architecture structure of fetch_unit_sandbox is

	constant c_immediate_four 	: std_logic_vector(31 downto 0) := x"00000004"; 
	signal s_pc_base		: std_logic_vector(31 downto 0); 
	signal s_pc_offset			: std_logic_vector(31 downto 0); 
	signal s_branch_or_jump		: std_logic; 
	signal s_branch_and_zero	: std_logic; 
	signal s_signal_signal_signal	: std_logic; 
	--handling a risc-v shift left one requirement
	signal s_imm_shifted		: std_logic_vector(31 downto 0); 
	

  component andg2 is 
    port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);

  end component; 


  component org2 is
    port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);

  end component; 

  
 component mux2t1_N is 
  generic(N : integer);
  port(i_S          : in std_logic;
       i_D0         : in std_logic_vector(N-1 downto 0);
       i_D1         : in std_logic_vector(N-1 downto 0);
       o_O          : out std_logic_vector(N-1 downto 0));

 end component;
 

  component ripple_carry_adderN is
  generic(N : integer); 
  port(A         : in std_logic_vector(N-1 downto 0);
       B         : in std_logic_vector(N-1 downto 0);
       Cin       : in std_logic := '0';
       Sum	 : out std_logic_vector(N-1 downto 0);  
       Cout      : out std_logic); 

  end component;

begin
  s_imm_shifted <= immediate_generate(30 downto 0) & '0'; 
  BranchZero_And : andg2
    port map(i_A 	=> BRANCH,
	     i_B 	=> ZERO,
             o_F 	=> s_branch_and_zero
	     );

  Jump_BZ_Or	: org2
    port map(i_A 	=> JUMP,
             i_B 	=> s_branch_and_zero, 
	     o_F 	=> s_branch_or_jump
	     ); 

  PC_AUX: mux2t1_N
    generic map(N => 32)
    port map(   i_S	=> s_branch_or_jump,
		i_D0	=> c_immediate_four,
		i_D1	=> s_imm_shifted,
		o_O	=>  s_pc_offset
		);
  PC_BASE: mux2t1_N
    generic map(N => 32)
    port map(   i_S	=> PC_SRC,
		i_D0	=> PC,
		i_D1	=> rs1,
		o_O	=>  s_pc_base
		);

  NEXT_PC_ADD: ripple_carry_adderN 
    generic map(N => 32)
    port map(	A	=> s_pc_offset,
		B	=> s_pc_base,
		Sum 	=> s_PC,
		Cout	=> open
		); 


end structure;
