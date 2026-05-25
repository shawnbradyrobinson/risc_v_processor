    .data
    .text
    .globl main
main:
    # test case: adding when the destination register is the same as rs1
    addi x1, x0, 5        # x1=5
    nop
    nop
    nop
    nop
    nop
    add x1, x1, x1        # x1=x1+x1=10

    # test case: adding when the destination register is the same as rs2
    addi x2, x0, 3        # x2=3
    nop
    nop
    nop
    nop
    nop
    add x2, x1, x2        # x2=10+3=13
    nop
    nop
    nop
    nop
    nop
    # test case: adding when both rs1 and rs2 are the same register
    add x3, x2, x2        # x3=1+13=26
    nop
    nop
    nop
    nop
    nop
    # test case: destination register is x0 and shouldn't be able to be written to
    addi x4, x0, 42       # x4=42
    nop
    nop
    nop
    nop
    nop
    add x0, x4, x3        # try to write result into x0
    nop
    nop
    nop
    nop
    nop
    add x5, x0, x0        # x5=x0+x0=0

    addi a7, x0, 93
    wfi
