# test_bge.s
.text
.globl main
main:
    addi x1, x0, 7
    addi x2, x0, 3
    bge  x1, x2, pass   # taken (7 >= 3)
    addi x3, x0, 99
pass:
    addi x4, x0, 1
    wfi
# Expected: x3=0, x4=1