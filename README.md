# risc_v_processor
Step 1 — Fill Out the Control Signals Spreadsheet
Your professor already gave you Proj1_control_signals.xlsx. This is your master plan.
Here's what you do:
What it is:
A table where every row = one instruction, every column = one control signal
Example of what it looks like:
Instruction | RegWrite | MemRead | MemWrite | ALUSrc | Branch | ALUOp
─────────────────────────────────────────────────────────────────────
addi        |    1     |    0    |    0     |   1    |   0    |  add
add         |    1     |    0    |    0     |   0    |   0    |  add
lw          |    1     |    1    |    0     |   1    |   0    |  add
sw          |    0     |    0    |    1     |   1    |   0    |  add
beq         |    0     |    0    |    0     |   0    |   1    |  sub
What each signal means:

RegWrite → should we save result to a register? (1=yes, 0=no)
MemRead → should we read from data memory? (lw needs this)
MemWrite → should we write to data memory? (sw needs this)
ALUSrc → does ALU use register value or immediate number?
Branch → is this a branch instruction?
ALUOp → what operation should ALU do?

Fill this out for ALL instructions before building anything! This is your blueprint.

🔧 Step 2 — Build Each Component One at a Time
Component 1: ALU (Arithmetic Logic Unit)
What it is:
The part that does all math and logic operations.
What it takes as input:

Two 32-bit numbers (operand A and operand B)
A control signal telling it what operation to do

What it outputs:

A 32-bit result
A "Zero" signal (1 if result is 0, used for branches)

Operations it must support:
ADD  → used by add, addi, lw, sw
SUB  → used by sub, beq, bne, branches
AND  → used by and, andi
OR   → used by or, ori
XOR  → used by xor, xori
SLT  → set less than (outputs 1 if A < B)
Shifts → sll, srl, sra (shift left/right)
How to test it:
Give it two numbers, pick an operation, check the output is correct. Test every single operation!

Component 2: Register File
What it is:
32 registers, each holding a 32-bit number. Like 32 boxes that store numbers temporarily.
What it takes as input:

Which register to read from (2 read ports)
Which register to write to
What value to write
RegWrite signal (1 = actually do the write)

What it outputs:

Two 32-bit values read from the registers

Important rules:

Register x0 is always 0 — you can never write to it!
Reading happens anytime
Writing only happens at the end of the clock cycle

How to test it:
Write a value to a register, then read it back and check it's the same value!

Component 3: Control Unit
What it is:
Looks at the opcode (first 7 bits) of every instruction and outputs all the control signals that tell every other component what to do.
What it takes as input:

The 7-bit opcode from the instruction
Sometimes funct3 and funct7 fields too

What it outputs:

RegWrite, MemRead, MemWrite, ALUSrc, Branch, ALUOp signals
Everything from your spreadsheet!

How it works:
Sees opcode 0010011 → "this is addi!"
  → sets RegWrite=1, ALUSrc=1, MemRead=0...

Sees opcode 0000011 → "this is lw!"
  → sets RegWrite=1, MemRead=1, ALUSrc=1...

Sees opcode 0100011 → "this is sw!"
  → sets RegWrite=0, MemWrite=1, ALUSrc=1...
How to test it:
Give it different opcodes and check all output signals match your spreadsheet!

Component 4: Immediate Generator
What it is:
Some instructions have a number baked directly into them (like addi x1, x2, 5 — the 5 is the immediate). This component extracts and sign-extends that number to 32 bits.
Different instruction types have the number in different bit positions:
I-type (addi, lw):     bits [31:20]
S-type (sw):           bits [31:25] and [11:7]
B-type (branches):     bits scattered around
U-type (lui, auipc):   bits [31:12]
J-type (jal):          bits scattered around
What it takes as input:

The full 32-bit instruction

What it outputs:

One 32-bit sign-extended immediate value


Component 5: Fetch Unit (Program Counter)
What it is:
Keeps track of which instruction to run next. Just a register that holds an address.
Normal case:
PC = PC + 4
(every instruction is 4 bytes, so next instruction is 4 bytes ahead)
Branch case:
IF branch taken:
  PC = PC + immediate (jump to branch target)
ELSE:
  PC = PC + 4
Jump case (jal):
PC = PC + immediate (always jump)
Jump register case (jalr):
PC = register value + immediate
What you need to build:

An adder that does PC + 4
Another adder that does PC + immediate
A MUX that picks between them based on branch/jump signals


Component 6: MUXes
What they are:
Simple selectors — pick between 2 or more inputs based on a control signal.
MUXes you need:
MUX 1 — ALU Source MUX:
  ALUSrc=0 → ALU gets register value
  ALUSrc=1 → ALU gets immediate value

MUX 2 — Write Back MUX:
  MemtoReg=0 → write ALU result to register
  MemtoReg=1 → write memory data to register (for lw)

MUX 3 — PC Source MUX:
  PCSrc=0 → PC = PC + 4 (normal)
  PCSrc=1 → PC = branch target (branch taken)

MUX 4 — For lui/auipc:
  Extra MUX needed for these special instructions

🔌 Step 3 — Connect Everything Together (Top Level)
Once all components work individually, connect them all in one top-level VHDL file. The data flows like this:
1. PC sends address → Instruction Memory
2. Instruction Memory outputs 32-bit instruction
3. Instruction goes to:
     → Control Unit (gets the opcode)
     → Register File (gets register numbers)
     → Immediate Generator (gets the immediate)
     → ALU Control (gets funct3/funct7)
4. Register File outputs two values → ALU
5. MUX picks between register value or immediate → ALU
6. ALU does the operation → outputs result + Zero flag
7. IF memory instruction:
     → Data Memory reads or writes
8. MUX picks between ALU result or memory data
9. Result written back to Register File
10. PC updates to next instruction

🧪 Step 4 — Testing
Test each component alone first:
ALU testbench        → test every operation
Register File tb     → test read/write
Control Unit tb      → test every opcode
Immediate Gen tb     → test every instruction type
Fetch Unit tb        → test PC+4 and branch targets
Then test the full processor:
Use the toolflow your professor gave you:
1. Write a simple assembly program (just addi first)
2. Run it in RARS simulator → see what result should be
3. Run it in QuestaSim with your VHDL → see what your processor outputs
4. Compare → they should match exactly!
Test programs you need to write:
Proj1_base_test.s  → uses every single instruction at least once
Proj1_cf_test.s    → tests all branches and jumps, call depth 5+
Proj1_mergesort.s  → sorts an array using Merge Sort algorithm

📅 Recommended Order to Build Things
Week 6:
  ✅ Draw schematic on paper
  ✅ Fill out control signals spreadsheet
  ✅ Divide work with your friend
  ✅ Read the toolflow manual

Week 7:
  → Build ALU (start simple — add/sub/and/or first)
  → Build Register File
  → Build Control Unit
  → Test each one separately in QuestaSim

Week 8:
  → Build Immediate Generator
  → Build Fetch Unit
  → Connect everything in top level file
  → Test with just addi first
  → Get addi, add, sub, lw, sw working
  → DEMO to TA ✅

Week 9:
  → Add branch instructions
  → Add jump instructions (jal, jalr)
  → Add remaining instructions
  → Test Merge Sort program
  → Synthesize to FPGA
  → Write lab report

🤝 How to Split Work With Your Friend
Jay:                        Friend:
─────────────────────────────────────────
ALU                         Register File
Control Unit                Immediate Generator
ALU testbench               Fetch Unit (PC logic)
Merge Sort program          Base test program
                            CF test program
Both of you work on:

Connecting everything in top level
Debugging together
Lab report


⚠️ Most Important Tips
1. START SMALL
   Get addi working first before adding more instructions
   
2. TEST AS YOU BUILD
   Don't build everything then test — test each part alone
   
3. DRAW FIRST
   Always update your schematic before writing VHDL
   
4. USE GIT EVERY DAY
   Push your work every day so nothing is lost
   git add . → git commit → git push origin active
   
5. DON'T PANIC
   The professor said you'll need extra MUXes not in the book
   That's expected and normal!
   
6. COMPARE WITH RARS
   RARS is your answer key — your processor must match it exactly

🎯 Your Very First Task Right Now:

Draw the block diagram from the PDF on paper
Open Proj1_control_signals.xlsx and fill in addi row first
Talk to your friend and decide who builds what
Start building the ALU — it's the most important component!