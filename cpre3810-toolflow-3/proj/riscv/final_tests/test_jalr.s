# test_jalr.s
.text
.globl main
main:
    la   x1, target
    jalr ra, x1, 0       # jump to target
    addi x2, x0, 99     # should NOT run
target:
    addi x3, x0, 1
    wfi
# Expected: x2=0, x3=1