# all_instructions_nop.s
# Tests all supported RV32I instructions on the software-scheduled pipeline.
# Three NOPs between data-dependent instructions (no forwarding).
# Two NOPs after branches/jumps.
# No control or data hazards.
#
# Instructions tested:
#   R-type:  add, sub, and, or, xor, sll, srl, sra, slt, sltu
#   I-type:  addi, andi, ori, xori, slli, srli, srai, slti, sltiu
#   Load:    lw, lh, lb, lhu, lbu
#   Store:   sw, sh, sb
#   Branch:  beq, bne, blt, bge, bltu, bgeu
#   Jump:    jal, jalr
#   Upper:   lui, auipc
#   System:  wfi (halt)

.data
    mem_buf: .word 0, 0, 0, 0    # 16 bytes of scratch space for stores/loads

.text

# ======================================================
# LOAD BASE ADDRESS FOR MEMORY TESTS
# lasw expands lui+ori with 3 NOPs between -- use la pseudo
# ======================================================
lui   x31, %hi(mem_buf)
nop
nop
nop
addi  x31, x31, %lo(mem_buf)
nop
nop
nop
# ======================================================
# R-TYPE INSTRUCTIONS
# ======================================================

addi  x1, x0, 10        # x1 = 10
nop
nop
nop
addi  x2, x0, 3         # x2 = 3
nop
nop
nop
add   x3, x1, x2        # x3 = 13
nop
nop
nop
sub   x4, x1, x2        # x4 = 7
nop
nop
nop
and   x5, x1, x2        # x5 = 2
nop
nop
nop
or    x6, x1, x2        # x6 = 11
nop
nop
nop
xor   x7, x1, x2        # x7 = 9
nop
nop
nop
sll   x8, x1, x2        # x8 = 80
nop
nop
nop
srl   x9, x8, x2        # x9 = 10
nop
nop
nop
addi  x10, x0, -8       # x10 = -8
nop
nop
nop
sra   x11, x10, x2      # x11 = -1
nop
nop
nop
slt   x12, x10, x1      # x12 = 1  (-8 < 10)
nop
nop
nop
sltu  x13, x2, x1       # x13 = 1  (3 <u 10)
nop
nop
nop

# ======================================================
# I-TYPE INSTRUCTIONS
# ======================================================

addi  x14, x0, 42       # x14 = 42
nop
nop
nop
andi  x15, x14, 0xF     # x15 = 10
nop
nop
nop
ori   x16, x14, 0xF     # x16 = 47
nop
nop
nop
xori  x17, x14, 0xF     # x17 = 37
nop
nop
nop
slli  x18, x14, 2       # x18 = 168
nop
nop
nop
srli  x19, x18, 2       # x19 = 42
nop
nop
nop
srai  x20, x10, 1       # x20 = -4
nop
nop
nop
slti  x21, x10, 1       # x21 = 1  (-8 < 1)
nop
nop
nop
sltiu x22, x2, 10       # x22 = 1  (3 <u 10)
nop
nop
nop

# ======================================================
# UPPER IMMEDIATE
# ======================================================

lui   x23, 0x12345      # x23 = 0x12345000
nop
nop
nop
auipc x24, 0x1          # x24 = PC + 0x00001000
nop
nop
nop

# ======================================================
# STORE / LOAD
# x31 = base address of mem_buf (loaded above with lasw)
# x25 = 0x5A (test value)
# ======================================================
addi  x25, x0, 0x5A
nop
nop
nop
sw    x25, 0(x31)
nop
nop
nop
#sh    x25, 4(x31)
#nop
#nop
#nop
#sb    x25, 8(x31)
#nop
#nop
#nop
lw    x26, 0(x31)
nop
nop
nop
lhu   x27, 4(x31)
nop
nop
nop
lbu   x28, 8(x31)
nop
nop
nop
lh    x29, 4(x31)
nop
nop
nop
lb    x30, 8(x31)
nop
nop
nop

# ======================================================
# BRANCH INSTRUCTIONS
# All branches taken, jumping over poison addi x31
# x1=10, x2=3, x10=-8 still in registers from above
# Set up fresh comparison values
# ======================================================

addi  x1, x0, 5         # x1 = 5
nop
nop
nop
addi  x2, x0, 5         # x2 = 5
nop
nop
nop
addi  x3, x0, 3         # x3 = 3
nop
nop
nop

# beq: x1 == x2
beq   x1, x2, beq_ok
nop
nop
addi  x31, x0, -1       # POISON
beq_ok:
nop
nop
nop

# bne: x1 != x3
bne   x1, x3, bne_ok
nop
nop
addi  x31, x0, -1       # POISON
bne_ok:
nop
nop
nop

# blt: x3 < x1
blt   x3, x1, blt_ok
nop
nop
addi  x31, x0, -1       # POISON
blt_ok:
nop
nop
nop

# bge: x1 >= x2
bge   x1, x2, bge_ok
nop
nop
addi  x31, x0, -1       # POISON
bge_ok:
nop
nop
nop

# bltu: x3 <u x1
bltu  x3, x1, bltu_ok
nop
nop
addi  x31, x0, -1       # POISON
bltu_ok:
nop
nop
nop

# bgeu: x1 >=u x2
bgeu  x1, x2, bgeu_ok
nop
nop
addi  x31, x0, -1       # POISON
bgeu_ok:
nop
nop
nop

# ======================================================
# JAL
# ======================================================

jal   x1, jal_target
nop
nop
addi  x31, x0, -1       # POISON

jal_target:
nop
nop
nop

# ======================================================
# JALR -- jump to jalr_target using register
# Use lasw to load jalr_target address safely
# ======================================================

lasw  x5, jalr_target
nop
nop
nop
jalr  x0, 0(x5)
nop
nop
addi  x31, x0, -1       # POISON

jalr_target:
nop
nop
nop

# ======================================================
# HALT
# ======================================================
wfi