# test_fwd_memwb_rs1.s
# Tests forwarding from MEM/WB stage to EX stage rs1
.text
.globl main
main:
    addi x1, x0, 10    # x1 = 10
    addi x2, x0, 5     # x2 = 5  (nop-like, lets x1 move to MEM/WB)
    addi x3, x1, 3     # x3 = 13 (needs x1 forwarded from MEM/WB)
    wfi
# Expected: x1=10, x2=5, x3=13