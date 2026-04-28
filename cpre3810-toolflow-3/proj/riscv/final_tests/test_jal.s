# test_jal.s
.text
.globl main
main:
    jal  ra, target      # jump, ra = PC+4
    addi x2, x0, 99     # should NOT run
target:
    addi x3, x0, 1
    wfi
# Expected: x2=0, x3=1, ra=address of addi x2