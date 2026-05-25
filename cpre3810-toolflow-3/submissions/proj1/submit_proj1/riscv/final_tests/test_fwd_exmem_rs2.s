# test_fwd_exmem_rs2.s
# Tests forwarding from EX/MEM stage to EX stage rs2
.text
.globl main
main:
    addi x1, x0, 10    # x1 = 10
    add  x2, x0, x1    # x2 = 10 (needs x1 forwarded from EX/MEM to rs2)
    wfi
# Expected: x1=10, x2=10