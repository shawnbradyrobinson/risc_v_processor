# test_bne.s
.text
.globl main
main:
    addi x1, x0, 5
    addi x2, x0, 6
    bne  x1, x2, pass   # taken (5 != 6)
    addi x3, x0, 99     # should NOT run
pass:
    addi x4, x0, 1
    wfi
# Expected: x3=0, x4=1