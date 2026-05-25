# test_fwd_branch.s
# Tests that forwarded value is correctly used in branch comparison
.text
.globl main
main:
    addi x1, x0, 5
    addi x2, x1, 0     # x2 = 5 (forwarded from EX/MEM)
    beq  x2, x1, pass  # should be taken (both = 5)
    addi x3, x0, 1     # should NOT execute
pass:
    addi x4, x0, 1     # x4 = 1
    wfi
# Expected: x3=0, x4=1