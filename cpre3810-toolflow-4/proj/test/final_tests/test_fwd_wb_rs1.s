# test_fwd_wb_rs1.s
# Tests WB to ID register file bypass for rs1
.text
.globl main
main:
    addi x1, x0, 10    # x1 = 10
    addi x2, x0, 5     # x2 = 5
    addi x3, x0, 3     # x3 = 3
    addi x4, x1, 1     # x4 = 11 (x1 bypassed from WB in register file)
    wfi
# Expected: x1=10, x2=5, x3=3, x4=11