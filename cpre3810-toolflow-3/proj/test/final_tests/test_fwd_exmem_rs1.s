# test_fwd_exmem_rs1.s
# Tests forwarding from EX/MEM stage to EX stage rs1
.text
.globl main
main:
    addi x1, x0, 10    # x1 = 10
    addi x2, x1, 5     # x2 = 15 (needs x1 forwarded from EX/MEM)
    wfi
# Expected: x1=10, x2=15