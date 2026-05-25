# test_fwd_priority.s
# Tests that EX/MEM forward takes priority over MEM/WB
# when both stages write to same register
.text
.globl main
main:
    addi x1, x0, 10    # x1 = 10
    addi x1, x0, 20    # x1 = 20 (overwrites, now in EX/MEM)
    addi x2, x1, 0     # x2 = 20 (must use EX/MEM value, not MEM/WB value of 10)
    wfi
# Expected: x1=20, x2=20