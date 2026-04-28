# test_fwd_memwb_rs2.s
# Tests forwarding from MEM/WB stage to EX stage rs2
.text
.globl main
main:
    addi x1, x0, 10    # x1 = 10
    addi x2, x0, 5     # x2 = 5
    add  x3, x2, x1    # x3 = 15 (needs x1 forwarded from MEM/WB to rs2)
    wfi
# Expected: x1=10, x2=5, x3=15