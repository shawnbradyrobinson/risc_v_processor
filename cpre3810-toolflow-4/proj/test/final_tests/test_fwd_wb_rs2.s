# test_fwd_wb_rs2.s
# Tests WB to ID register file bypass for rs2
.text
.globl main
main:
    addi x1, x0, 10    # x1 = 10
    addi x2, x0, 5     # x2 = 5
    addi x3, x0, 3     # x3 = 3
    add  x4, x3, x1    # x4 = 13 (x1 bypassed from WB to rs2)
    wfi
# Expected: x1=10, x2=5, x3=3, x4=13