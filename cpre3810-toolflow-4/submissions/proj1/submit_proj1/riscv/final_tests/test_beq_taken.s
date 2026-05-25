# test_beq_taken.s
.text
.globl main
main:
    addi x1, x0, 5
    addi x2, x0, 5
    beq  x1, x2, pass   # taken, skip addi
    addi x3, x0, 99     # should NOT run
pass:
    addi x4, x0, 1
    wfi
# Expected: x3=0, x4=1