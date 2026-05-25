# Proj1_cf_test.s (RARS SAFE VERSION)

.data
msg: .asciz "Done\n"

.text
.globl main
# --- 1. BOILERPLATE: Environment Setup --- 
lui sp, 0x80000 
addi sp, sp, -4 # sp = 0x7FFFFFFC 
addi ra, x0, 0 
# --- 2. MMIO Display Init --- 
lui x3, 0x10010 
addi x3, x3, 0x0010 
addi x4, x0, 60 
sw x4, 0(x3)
########################################
# main
########################################
main:
    li   a0, 5
    jal  x1, func1

    li   a7, 10
    ecall


########################################
# func1 (BEQ)
########################################
func1:
    addi sp, sp, -8
    sw   x1, 4(sp)

    li   t0, 5
    beq  a0, t0, func1_equal

    addi a0, a0, 1
    j    func1_next

func1_equal:
    addi a0, a0, 2

func1_next:
    jal  x1, func2

    lw   x1, 4(sp)
    addi sp, sp, 8
    jalr x0, x1, 0


########################################
# func2 (BNE)
########################################
func2:
    addi sp, sp, -8
    sw   x1, 4(sp)

    li   t0, 10
    bne  a0, t0, func2_noteq

    addi a0, a0, -3
    j    func2_next

func2_noteq:
    addi a0, a0, 3

func2_next:
    jal  x1, func3

    lw   x1, 4(sp)
    addi sp, sp, 8
    jalr x0, x1, 0


########################################
# func3 (BLT)
########################################
func3:
    addi sp, sp, -8
    sw   x1, 4(sp)

    li   t0, 20
    blt  a0, t0, func3_less

    addi a0, a0, -5
    j    func3_next

func3_less:
    addi a0, a0, 5

func3_next:
    jal  x1, func4

    lw   x1, 4(sp)
    addi sp, sp, 8
    jalr x0, x1, 0


########################################
# func4 (BGE)
########################################
func4:
    addi sp, sp, -8
    sw   x1, 4(sp)

    li   t0, 15
    bge  a0, t0, func4_ge

    addi a0, a0, 7
    j    func4_next

func4_ge:
    addi a0, a0, -7

func4_next:
    jal  x1, func5

    lw   x1, 4(sp)
    addi sp, sp, 8
    jalr x0, x1, 0


########################################
# func5 (JALR explicitly)
########################################
func5:
    addi sp, sp, -8
    sw   x1, 4(sp)

    addi a0, a0, 1

    # explicit jalr return
    lw   t0, 4(sp)
    addi sp, sp, 8
    jalr x0, t0, 0
