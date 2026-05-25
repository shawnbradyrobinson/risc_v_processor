# test_beq_nottaken.s
.text
.globl main
main:
    addi x1, x0, 5
    addi x2, x0, 6
    beq  x1, x2, skip   # not taken
    addi x3, x0, 1      # should run
    beq  x0, x0, done
skip:
    addi x3, x0, 99     # should NOT run
done:
    wfi
# Expected: x3=1