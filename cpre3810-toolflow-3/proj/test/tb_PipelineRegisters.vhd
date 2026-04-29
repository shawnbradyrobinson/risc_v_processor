-------------------------------------------------------------------------
-- tb_PipelineRegisters.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: Testbench that instantiates all four pipeline registers
-- in a chain and tests:
--   1. Normal flow: value inserted at IF/ID appears at WB 4 cycles later
--   2. New values inserted every cycle
--   3. Individual stall of each register
--   4. Individual flush of each register
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_PipelineRegisters is

end tb_PipelineRegisters;

architecture behavior of tb_PipelineRegisters is

    -- ===== COMPONENT DECLARATIONS ===== --

    component IFID_PipelineRegister is
        port(
            iCLK        : in std_logic;
            iRST        : in std_logic;
            iWE         : in std_logic;
            iFLUSH      : in std_logic;
            IF_PC       : in std_logic_vector(31 downto 0);
            IF_Instr    : in std_logic_vector(31 downto 0);
            IF_PC_Plus4 : in std_logic_vector(31 downto 0);
            ID_PC       : out std_logic_vector(31 downto 0);
            ID_Instr    : out std_logic_vector(31 downto 0);
            ID_PC_Plus4 : out std_logic_vector(31 downto 0)
        );
    end component;

    component IDEX_PipelineRegister is
        port(
            iCLK        : in std_logic;
            iRST        : in std_logic;
            iWE         : in std_logic;
            iFLUSH      : in std_logic;
            ID_PC           : in std_logic_vector(31 downto 0);
            ID_Instr        : in std_logic_vector(31 downto 0);
            ID_PC_Plus4     : in std_logic_vector(31 downto 0);
            ID_rs1_out      : in std_logic_vector(31 downto 0);
            ID_rs2_out      : in std_logic_vector(31 downto 0);
            ID_ImmGen       : in std_logic_vector(31 downto 0);
            ID_ALUSrc       : in std_logic;
            ID_ALUCtrl      : in std_logic_vector(3 downto 0);
            ID_isLUI        : in std_logic;
            ID_isAUIPC      : in std_logic;
            ID_Jump         : in std_logic;
            ID_Branch       : in std_logic;
            ID_PC_SRC       : in std_logic;
            ID_MemWrite     : in std_logic;
            ID_MemRead      : in std_logic;
            ID_RegWrite     : in std_logic;
            ID_MemToReg     : in std_logic_vector(1 downto 0);
            ID_Halt         : in std_logic;
            EX_PC           : out std_logic_vector(31 downto 0);
            EX_Instr        : out std_logic_vector(31 downto 0);
            EX_PC_Plus4     : out std_logic_vector(31 downto 0);
            EX_rs1_out      : out std_logic_vector(31 downto 0);
            EX_rs2_out      : out std_logic_vector(31 downto 0);
            EX_ImmGen       : out std_logic_vector(31 downto 0);
            EX_ALUSrc       : out std_logic;
            EX_ALUCtrl      : out std_logic_vector(3 downto 0);
            EX_isLUI        : out std_logic;
            EX_isAUIPC      : out std_logic;
            EX_MemWrite     : out std_logic;
            EX_MemRead      : out std_logic;
            EX_RegWrite     : out std_logic;
            EX_MemToReg     : out std_logic_vector(1 downto 0);
            EX_Jump         : out std_logic;
            EX_Branch       : out std_logic;
            EX_PC_SRC       : out std_logic;
            EX_Halt         : out std_logic
        );
    end component;

    component EXMEM_PipelineRegister is
        port(
            iCLK            : in std_logic;
            iRST            : in std_logic;
            iWE             : in std_logic;
            iFLUSH          : in std_logic;
            EX_PC           : in std_logic_vector(31 downto 0);
            EX_Instr        : in std_logic_vector(31 downto 0);
            EX_PC_Plus4     : in std_logic_vector(31 downto 0);
            EX_ALU_Result   : in std_logic_vector(31 downto 0);
            EX_rs2_out      : in std_logic_vector(31 downto 0);
            EX_rd_addr      : in std_logic_vector(4 downto 0);
            EX_MemWrite     : in std_logic;
            EX_MemRead      : in std_logic;
            EX_BranchTaken  : in std_logic;
            EX_Jump         : in std_logic;
            EX_PC_SRC       : in std_logic;
            EX_rs1_out      : in std_logic_vector(31 downto 0);
            EX_ImmGen       : in std_logic_vector(31 downto 0);
            EX_Branch       : in std_logic;
            EX_RegWrite     : in std_logic;
            EX_MemToReg     : in std_logic_vector(1 downto 0);
            EX_Halt         : in std_logic;
            MEM_PC          : out std_logic_vector(31 downto 0);
            MEM_Instr       : out std_logic_vector(31 downto 0);
            MEM_PC_Plus4    : out std_logic_vector(31 downto 0);
            MEM_BranchTaken : out std_logic;
            MEM_Jump        : out std_logic;
            MEM_PC_SRC      : out std_logic;
            MEM_rs1_out     : out std_logic_vector(31 downto 0);
            MEM_Branch      : out std_logic;
            MEM_ImmGen      : out std_logic_vector(31 downto 0);
            MEM_ALU_Result  : out std_logic_vector(31 downto 0);
            MEM_rs2_out     : out std_logic_vector(31 downto 0);
            MEM_rd_addr     : out std_logic_vector(4 downto 0);
            MEM_Halt        : out std_logic;
            MEM_MemWrite    : out std_logic;
            MEM_MemRead     : out std_logic;
            MEM_RegWrite    : out std_logic;
            MEM_MemToReg    : out std_logic_vector(1 downto 0)
        );
    end component;

    component MEMWB_PipelineRegister is
        port(
            iCLK            : in std_logic;
            iRST            : in std_logic;
            iWE             : in std_logic;
            MEM_PC          : in std_logic_vector(31 downto 0);
            MEM_PC_Plus4    : in std_logic_vector(31 downto 0);
            MEM_ALU_Result  : in std_logic_vector(31 downto 0);
            MEM_DMemOut     : in std_logic_vector(31 downto 0);
            MEM_rd_addr     : in std_logic_vector(4 downto 0);
            MEM_RegWrite    : in std_logic;
            MEM_MemToReg    : in std_logic_vector(1 downto 0);
            MEM_Halt        : in std_logic;
            WB_PC           : out std_logic_vector(31 downto 0);
            WB_PC_Plus4     : out std_logic_vector(31 downto 0);
            WB_ALU_Result   : out std_logic_vector(31 downto 0);
            WB_DMemOut      : out std_logic_vector(31 downto 0);
            WB_rd_addr      : out std_logic_vector(4 downto 0);
            WB_Halt         : out std_logic;
            WB_RegWrite     : out std_logic;
            WB_MemToReg     : out std_logic_vector(1 downto 0)
        );
    end component;

    -- ===== CLOCK/RESET ===== --
    constant c_CLK_PERIOD : time := 10 ns;
    signal s_CLK : std_logic := '0';
    signal s_RST : std_logic := '0';

    -- ===== IF STAGE INPUTS ===== --
    signal s_IF_WE      : std_logic := '1';
    signal s_IF_FLUSH   : std_logic := '0';
    signal s_IF_PC      : std_logic_vector(31 downto 0) := x"00400000";
    signal s_IF_Instr   : std_logic_vector(31 downto 0) := x"00000013"; -- NOP
    signal s_IF_PC4     : std_logic_vector(31 downto 0) := x"00400004";

    -- ===== IF/ID -> ID/EX wires ===== --
    signal s_ID_PC      : std_logic_vector(31 downto 0);
    signal s_ID_Instr   : std_logic_vector(31 downto 0);
    signal s_ID_PC4     : std_logic_vector(31 downto 0);

    -- ===== ID STAGE CONTROL INPUTS ===== --
    signal s_ID_WE      : std_logic := '1';
    signal s_ID_FLUSH   : std_logic := '0';
    signal s_ID_rs1     : std_logic_vector(31 downto 0) := x"00000001";
    signal s_ID_rs2     : std_logic_vector(31 downto 0) := x"00000002";
    signal s_ID_Imm     : std_logic_vector(31 downto 0) := x"00000000";
    signal s_ID_ALUSrc  : std_logic := '0';
    signal s_ID_ALUCtrl : std_logic_vector(3 downto 0) := "0000";
    signal s_ID_isLUI   : std_logic := '0';
    signal s_ID_isAUIPC : std_logic := '0';
    signal s_ID_Jump    : std_logic := '0';
    signal s_ID_Branch  : std_logic := '0';
    signal s_ID_PC_SRC  : std_logic := '0';
    signal s_ID_MemWr   : std_logic := '0';
    signal s_ID_MemRd   : std_logic := '0';
    signal s_ID_RegWr   : std_logic := '0';
    signal s_ID_MemToReg: std_logic_vector(1 downto 0) := "00";
    signal s_ID_Halt    : std_logic := '0';

    -- ===== ID/EX -> EX/MEM wires ===== --
    signal s_EX_PC          : std_logic_vector(31 downto 0);
    signal s_EX_Instr       : std_logic_vector(31 downto 0);
    signal s_EX_PC4         : std_logic_vector(31 downto 0);
    signal s_EX_rs1         : std_logic_vector(31 downto 0);
    signal s_EX_rs2         : std_logic_vector(31 downto 0);
    signal s_EX_Imm         : std_logic_vector(31 downto 0);
    signal s_EX_ALUSrc      : std_logic;
    signal s_EX_ALUCtrl     : std_logic_vector(3 downto 0);
    signal s_EX_isLUI       : std_logic;
    signal s_EX_isAUIPC     : std_logic;
    signal s_EX_Jump        : std_logic;
    signal s_EX_Branch      : std_logic;
    signal s_EX_PC_SRC      : std_logic;
    signal s_EX_MemWr       : std_logic;
    signal s_EX_MemRd       : std_logic;
    signal s_EX_RegWr       : std_logic;
    signal s_EX_MemToReg    : std_logic_vector(1 downto 0);
    signal s_EX_Halt        : std_logic;

    -- ===== EX STAGE INPUTS ===== --
    signal s_EX_WE          : std_logic := '1';
    signal s_EX_FLUSH       : std_logic := '0';
    signal s_EX_ALU_Result  : std_logic_vector(31 downto 0) := x"00000000";
    signal s_EX_BranchTaken : std_logic := '0';

    -- ===== EX/MEM -> MEM/WB wires ===== --
    signal s_MEM_PC         : std_logic_vector(31 downto 0);
    signal s_MEM_Instr      : std_logic_vector(31 downto 0);
    signal s_MEM_PC4        : std_logic_vector(31 downto 0);
    signal s_MEM_ALU_Result : std_logic_vector(31 downto 0);
    signal s_MEM_rs2        : std_logic_vector(31 downto 0);
    signal s_MEM_rd_addr    : std_logic_vector(4 downto 0);
    signal s_MEM_MemWr      : std_logic;
    signal s_MEM_MemRd      : std_logic;
    signal s_MEM_RegWr      : std_logic;
    signal s_MEM_MemToReg   : std_logic_vector(1 downto 0);
    signal s_MEM_Halt       : std_logic;
    signal s_MEM_Jump       : std_logic;
    signal s_MEM_Branch     : std_logic;
    signal s_MEM_BranchTaken: std_logic;
    signal s_MEM_PC_SRC     : std_logic;
    signal s_MEM_rs1        : std_logic_vector(31 downto 0);
    signal s_MEM_Imm        : std_logic_vector(31 downto 0);

    -- ===== MEM STAGE INPUTS ===== --
    signal s_MEM_WE         : std_logic := '1';
    signal s_MEM_DMemOut    : std_logic_vector(31 downto 0) := x"00000000";

    -- ===== WB OUTPUTS ===== --
    signal s_WB_PC          : std_logic_vector(31 downto 0);
    signal s_WB_PC4         : std_logic_vector(31 downto 0);
    signal s_WB_ALU_Result  : std_logic_vector(31 downto 0);
    signal s_WB_DMemOut     : std_logic_vector(31 downto 0);
    signal s_WB_rd_addr     : std_logic_vector(4 downto 0);
    signal s_WB_RegWr       : std_logic;
    signal s_WB_MemToReg    : std_logic_vector(1 downto 0);
    signal s_WB_Halt        : std_logic;

begin

    -- ===== CLOCK GENERATION ===== --
    s_CLK <= not s_CLK after c_CLK_PERIOD / 2;

    -- ===== INSTANTIATE ALL FOUR REGISTERS IN CHAIN ===== --

    IFID_REG: IFID_PipelineRegister
        port map(
            iCLK        => s_CLK,
            iRST        => s_RST,
            iWE         => s_IF_WE,
            iFLUSH      => s_IF_FLUSH,
            IF_PC       => s_IF_PC,
            IF_Instr    => s_IF_Instr,
            IF_PC_Plus4 => s_IF_PC4,
            ID_PC       => s_ID_PC,
            ID_Instr    => s_ID_Instr,
            ID_PC_Plus4 => s_ID_PC4
        );

    IDEX_REG: IDEX_PipelineRegister
        port map(
            iCLK        => s_CLK,
            iRST        => s_RST,
            iWE         => s_ID_WE,
            iFLUSH      => s_ID_FLUSH,
            ID_PC       => s_ID_PC,
            ID_Instr    => s_ID_Instr,
            ID_PC_Plus4 => s_ID_PC4,
            ID_rs1_out  => s_ID_rs1,
            ID_rs2_out  => s_ID_rs2,
            ID_ImmGen   => s_ID_Imm,
            ID_ALUSrc   => s_ID_ALUSrc,
            ID_ALUCtrl  => s_ID_ALUCtrl,
            ID_isLUI    => s_ID_isLUI,
            ID_isAUIPC  => s_ID_isAUIPC,
            ID_Jump     => s_ID_Jump,
            ID_Branch   => s_ID_Branch,
            ID_PC_SRC   => s_ID_PC_SRC,
            ID_MemWrite => s_ID_MemWr,
            ID_MemRead  => s_ID_MemRd,
            ID_RegWrite => s_ID_RegWr,
            ID_MemToReg => s_ID_MemToReg,
            ID_Halt     => s_ID_Halt,
            EX_PC       => s_EX_PC,
            EX_Instr    => s_EX_Instr,
            EX_PC_Plus4 => s_EX_PC4,
            EX_rs1_out  => s_EX_rs1,
            EX_rs2_out  => s_EX_rs2,
            EX_ImmGen   => s_EX_Imm,
            EX_ALUSrc   => s_EX_ALUSrc,
            EX_ALUCtrl  => s_EX_ALUCtrl,
            EX_isLUI    => s_EX_isLUI,
            EX_isAUIPC  => s_EX_isAUIPC,
            EX_Jump     => s_EX_Jump,
            EX_Branch   => s_EX_Branch,
            EX_PC_SRC   => s_EX_PC_SRC,
            EX_MemWrite => s_EX_MemWr,
            EX_MemRead  => s_EX_MemRd,
            EX_RegWrite => s_EX_RegWr,
            EX_MemToReg => s_EX_MemToReg,
            EX_Halt     => s_EX_Halt
        );

    EXMEM_REG: EXMEM_PipelineRegister
        port map(
            iCLK            => s_CLK,
            iRST            => s_RST,
            iWE             => s_EX_WE,
            iFLUSH          => s_EX_FLUSH,
            EX_PC           => s_EX_PC,
            EX_Instr        => s_EX_Instr,
            EX_PC_Plus4     => s_EX_PC4,
            EX_ALU_Result   => s_EX_ALU_Result,
            EX_rs2_out      => s_EX_rs2,
            EX_rd_addr      => s_EX_Instr(11 downto 7),
            EX_MemWrite     => s_EX_MemWr,
            EX_MemRead      => s_EX_MemRd,
            EX_BranchTaken  => s_EX_BranchTaken,
            EX_Jump         => s_EX_Jump,
            EX_PC_SRC       => s_EX_PC_SRC,
            EX_rs1_out      => s_EX_rs1,
            EX_ImmGen       => s_EX_Imm,
            EX_Branch       => s_EX_Branch,
            EX_RegWrite     => s_EX_RegWr,
            EX_MemToReg     => s_EX_MemToReg,
            EX_Halt         => s_EX_Halt,
            MEM_PC          => s_MEM_PC,
            MEM_Instr       => s_MEM_Instr,
            MEM_PC_Plus4    => s_MEM_PC4,
            MEM_BranchTaken => s_MEM_BranchTaken,
            MEM_Jump        => s_MEM_Jump,
            MEM_PC_SRC      => s_MEM_PC_SRC,
            MEM_rs1_out     => s_MEM_rs1,
            MEM_Branch      => s_MEM_Branch,
            MEM_ImmGen      => s_MEM_Imm,
            MEM_ALU_Result  => s_MEM_ALU_Result,
            MEM_rs2_out     => s_MEM_rs2,
            MEM_rd_addr     => s_MEM_rd_addr,
            MEM_Halt        => s_MEM_Halt,
            MEM_MemWrite    => s_MEM_MemWr,
            MEM_MemRead     => s_MEM_MemRd,
            MEM_RegWrite    => s_MEM_RegWr,
            MEM_MemToReg    => s_MEM_MemToReg
        );

    MEMWB_REG: MEMWB_PipelineRegister
        port map(
            iCLK            => s_CLK,
            iRST            => s_RST,
            iWE             => s_MEM_WE,
            MEM_PC          => s_MEM_PC,
            MEM_PC_Plus4    => s_MEM_PC4,
            MEM_ALU_Result  => s_MEM_ALU_Result,
            MEM_DMemOut     => s_MEM_DMemOut,
            MEM_rd_addr     => s_MEM_rd_addr,
            MEM_RegWrite    => s_MEM_RegWr,
            MEM_MemToReg    => s_MEM_MemToReg,
            MEM_Halt        => s_MEM_Halt,
            WB_PC           => s_WB_PC,
            WB_PC_Plus4     => s_WB_PC4,
            WB_ALU_Result   => s_WB_ALU_Result,
            WB_DMemOut      => s_WB_DMemOut,
            WB_rd_addr      => s_WB_rd_addr,
            WB_Halt         => s_WB_Halt,
            WB_RegWrite     => s_WB_RegWr,
            WB_MemToReg     => s_WB_MemToReg
        );

    -- ===== STIMULUS PROCESS ===== --
    process
    begin

        -- ================================================
        -- TEST 1: RESET
        -- Verify all outputs clear on reset
        -- ================================================
        report "TEST 1: Reset";
        s_RST <= '1';
        wait for c_CLK_PERIOD * 2;
        s_RST <= '0';
        wait for c_CLK_PERIOD;

        -- ================================================
        -- TEST 2: NORMAL FLOW
        -- Insert a distinctive instruction at IF stage.
        -- After 4 clock edges it should appear at WB.
        -- We track PC = 0xDEADBEEF as our marker value.
        -- ================================================
        report "TEST 2: Normal flow - marker value propagates through all 4 registers";

        -- Cycle 1: insert marker into IF stage
        s_IF_PC     <= x"DEADBEEF";
        s_IF_Instr  <= x"00A50533"; -- add x10, x10, x10 (arbitrary real instruction)
        s_IF_PC4    <= x"DEADBEF3";
        s_ID_RegWr  <= '1';         -- set a distinctive control signal too
        s_ID_Halt   <= '0';
        wait for c_CLK_PERIOD;      -- cycle 1: IF -> ID

        -- Cycle 2: change IF inputs to something different
        -- marker should now be in ID/EX
        s_IF_PC     <= x"00400004";
        s_IF_Instr  <= x"00000013"; -- NOP
        s_IF_PC4    <= x"00400008";
        wait for c_CLK_PERIOD;      -- cycle 2: ID -> EX

        -- Cycle 3: marker should now be in EX/MEM
        wait for c_CLK_PERIOD;      -- cycle 3: EX -> MEM

        -- Cycle 4: marker should now be in MEM/WB
        wait for c_CLK_PERIOD;      -- cycle 4: MEM -> WB

        -- Now check WB outputs contain our marker
        assert s_WB_PC = x"DEADBEEF"
            report "FAIL TEST 2: WB_PC should be 0xDEADBEEF" severity error;
        assert s_WB_RegWr = '1'
            report "FAIL TEST 2: WB_RegWrite should be 1" severity error;
        report "TEST 2 complete - check waveform for WB_PC = 0xDEADBEEF";

        -- ================================================
        -- TEST 3: NEW VALUES EVERY CYCLE
        -- Insert 4 different PC values back to back,
        -- verify each one propagates correctly
        -- ================================================
        report "TEST 3: New values inserted every cycle";
        s_RST <= '1'; wait for c_CLK_PERIOD; s_RST <= '0';

        -- Inject 4 unique values one per cycle
        s_IF_PC <= x"00400000"; s_IF_Instr <= x"00000001";
        wait for c_CLK_PERIOD;
        s_IF_PC <= x"00400004"; s_IF_Instr <= x"00000002";
        wait for c_CLK_PERIOD;
        s_IF_PC <= x"00400008"; s_IF_Instr <= x"00000003";
        wait for c_CLK_PERIOD;
        s_IF_PC <= x"0040000C"; s_IF_Instr <= x"00000004";
        wait for c_CLK_PERIOD;

        -- First value should now be at WB
        assert s_WB_PC = x"00400000"
            report "FAIL TEST 3: First value not at WB" severity error;
        -- Second value should be at MEM
        assert s_MEM_PC = x"00400004"
            report "FAIL TEST 3: Second value not at MEM" severity error;
        -- Third value should be at EX
        assert s_EX_PC = x"00400008"
            report "FAIL TEST 3: Third value not at EX" severity error;
        -- Fourth value should be at ID
        assert s_ID_PC = x"0040000C"
            report "FAIL TEST 3: Fourth value not at ID" severity error;
        report "TEST 3 complete";

        -- ================================================
        -- TEST 4: STALL IF/ID ONLY
        -- Insert a value, then stall IF/ID for 2 cycles.
        -- The value should stay frozen in IF/ID while
        -- the rest of the pipeline advances normally.
        -- ================================================
        report "TEST 4: Individual stall of IF/ID register";
        s_RST <= '1'; wait for c_CLK_PERIOD; s_RST <= '0';

        s_IF_PC     <= x"AAAAAAAA";
        s_IF_Instr  <= x"AAAAAAAA";
        wait for c_CLK_PERIOD; -- value enters IF/ID

        -- Now stall IF/ID for 2 cycles
        s_IF_WE     <= '0';
        s_IF_PC     <= x"BBBBBBBB"; -- this should NOT enter IF/ID
        s_IF_Instr  <= x"BBBBBBBB";
        wait for c_CLK_PERIOD;

        assert s_ID_PC = x"AAAAAAAA"
            report "FAIL TEST 4: IF/ID should be frozen with 0xAAAAAAAA" severity error;
        wait for c_CLK_PERIOD;
        assert s_ID_PC = x"AAAAAAAA"
            report "FAIL TEST 4: IF/ID still frozen after second stall cycle" severity error;

        -- Release stall
        s_IF_WE <= '1';
        wait for c_CLK_PERIOD;
        assert s_ID_PC = x"BBBBBBBB"
            report "FAIL TEST 4: IF/ID should advance to 0xBBBBBBBB after stall release" severity error;
        report "TEST 4 complete";

        -- ================================================
        -- TEST 5: STALL ID/EX ONLY
        -- ================================================
        report "TEST 5: Individual stall of ID/EX register";
        s_RST <= '1'; wait for c_CLK_PERIOD; s_RST <= '0';

        s_IF_PC     <= x"CCCCCCCC";
        s_IF_Instr  <= x"CCCCCCCC";
        wait for c_CLK_PERIOD; -- into IF/ID

        s_ID_WE     <= '0'; -- stall ID/EX
        s_IF_PC     <= x"DDDDDDDD";
        wait for c_CLK_PERIOD; -- ID/EX should freeze

        assert s_EX_PC = x"CCCCCCCC"
            report "FAIL TEST 5: ID/EX should be frozen with 0xCCCCCCCC" severity error;

        s_ID_WE <= '1';
        report "TEST 5 complete";

        -- ================================================
        -- TEST 6: FLUSH IF/ID
        -- Insert a value, then flush IF/ID.
        -- The output should become NOP (0x00000013)
        -- ================================================
        report "TEST 6: Flush IF/ID register";
        s_RST <= '1'; wait for c_CLK_PERIOD; s_RST <= '0';

        s_IF_PC     <= x"EEEEEEEE";
        s_IF_Instr  <= x"EEEEEEEE";
        s_IF_FLUSH  <= '1'; -- flush on same cycle
        wait for c_CLK_PERIOD;

        assert s_ID_Instr = x"00000013"
            report "FAIL TEST 6: IF/ID flush should produce NOP instruction" severity error;
        assert s_ID_PC = x"00000000"
            report "FAIL TEST 6: IF/ID flush should zero the PC" severity error;

        s_IF_FLUSH <= '0';
        report "TEST 6 complete";

        -- ================================================
        -- TEST 7: FLUSH ID/EX
        -- Verify control signals become zero (no RegWrite,
        -- no MemWrite etc.) when ID/EX is flushed
        -- ================================================
        report "TEST 7: Flush ID/EX register";
        s_RST <= '1'; wait for c_CLK_PERIOD; s_RST <= '0';

        -- Set up some active control signals
        s_ID_RegWr  <= '1';
        s_ID_MemWr  <= '1';
        s_ID_Jump   <= '1';
        s_IF_PC     <= x"12345678";
        s_IF_Instr  <= x"12345678";
        wait for c_CLK_PERIOD; -- values in IF/ID

        -- Now flush ID/EX as the value moves from IF/ID to ID/EX
        s_ID_FLUSH  <= '1';
        wait for c_CLK_PERIOD;

        -- Control signals should all be zero (bubble)
        assert s_EX_RegWr = '0'
            report "FAIL TEST 7: ID/EX flush should zero RegWrite" severity error;
        assert s_EX_MemWr = '0'
            report "FAIL TEST 7: ID/EX flush should zero MemWrite" severity error;
        assert s_EX_Jump = '0'
            report "FAIL TEST 7: ID/EX flush should zero Jump" severity error;

        s_ID_FLUSH  <= '0';
        s_ID_RegWr  <= '0';
        s_ID_MemWr  <= '0';
        s_ID_Jump   <= '0';
        report "TEST 7 complete";

        -- ================================================
        -- TEST 8: FLUSH EX/MEM
        -- Verify control signals zero out when EX/MEM flushed
        -- ================================================
        report "TEST 8: Flush EX/MEM register";
        s_RST <= '1'; wait for c_CLK_PERIOD; s_RST <= '0';

        s_ID_RegWr  <= '1';
        s_ID_MemWr  <= '1';
        s_IF_PC     <= x"CAFEBABE";
        s_IF_Instr  <= x"CAFEBABE";
        wait for c_CLK_PERIOD; -- into IF/ID
        wait for c_CLK_PERIOD; -- into ID/EX

        s_EX_FLUSH  <= '1';
        wait for c_CLK_PERIOD; -- ID/EX -> EX/MEM with flush

        assert s_MEM_RegWr = '0'
            report "FAIL TEST 8: EX/MEM flush should zero RegWrite" severity error;
        assert s_MEM_MemWr = '0'
            report "FAIL TEST 8: EX/MEM flush should zero MemWrite" severity error;

        s_EX_FLUSH  <= '0';
        s_ID_RegWr  <= '0';
        s_ID_MemWr  <= '0';
        report "TEST 8 complete";

        -- ================================================
        -- TEST 9: STALL + FLUSH PRIORITY
        -- Flush should override stall -- even if WE=0,
        -- a flush should still write zeros into the register
        -- ================================================
        report "TEST 9: Flush overrides stall (priority check)";
        s_RST <= '1'; wait for c_CLK_PERIOD; s_RST <= '0';

        s_IF_PC     <= x"FACADE00";
        s_IF_Instr  <= x"FACADE00";
        wait for c_CLK_PERIOD;

        -- Assert both stall AND flush simultaneously
        s_IF_WE     <= '0';  -- stall
        s_IF_FLUSH  <= '1';  -- flush -- should win
        s_IF_PC     <= x"FACADE01";
        wait for c_CLK_PERIOD;

        assert s_ID_Instr = x"00000013"
            report "FAIL TEST 9: Flush should override stall, producing NOP" severity error;

        s_IF_WE     <= '1';
        s_IF_FLUSH  <= '0';
        report "TEST 9 complete";

        report "ALL TESTS COMPLETE - review waveform for detailed signal inspection";
        wait;

    end process;

end behavior;