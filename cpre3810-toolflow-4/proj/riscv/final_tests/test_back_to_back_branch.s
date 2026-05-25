# test_back_to_back_branch.s
# Two branches in close succession
.text
.globl main
main:
    addi x1, x0, 1
    addi x2, x0, 1
    beq  x1, x2, next   # taken
    addi x5, x0, 99     # should NOT run
next:
    addi x3, x0, 2
    addi x4, x0, 2
    beq  x3, x4, done   # taken
    addi x5, x0, 99     # should NOT run
done:
    addi x6, x0, 1
    wfi
# Expected: x5=0, x6=1