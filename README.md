# risc_v_processor
I have done basic control unit and alucontrol part and spreadsheet whole part 
if you not understand what i have done 




Why ALUOp exists
The control unit only sees the opcode (7 bits). The opcode tells you the instruction TYPE but not the exact operation.
For example, ALL these have the same opcode 0110011:
add, sub, and, or, xor, slt, sll, srl, sra

So the control unit says "I don't know which one, here's a hint" → that hint is ALUOp.

What ALUOp means
ALUOp      Meaning
00    Always ADD — don't think, just add (loads/stores need address calculation)
01    Always SUB — don't think, just subtract (branches need comparison)
10   Go figure it out — R-type, check funct3 + funct7
11     Go figure it out — I-type, check funct3

What ALU Control does with it

Gets ALUOp + funct3 + funct7_5
Outputs a 4-bit ALUCtrl that tells the ALU exactly what to do

ALUOp=00  →  ignore funct fields  →  ALUCtrl = ADD
ALUOp=01  →  ignore funct fields  →  ALUCtrl = SUB
ALUOp=10  →  read funct3 + funct7 →  ALUCtrl = ADD/SUB/AND/OR/XOR/SLL...
ALUOp=11  →  read funct3 only     →  ALUCtrl = ADDI/ANDI/ORI/XOR

One line summary

Control unit gives a rough hint (ALUOp), ALU control uses that hint + funct fields to give the ALU its exact instruction (ALUCtrl).

i think this will help you to work on fetch and new signals in control unit 

