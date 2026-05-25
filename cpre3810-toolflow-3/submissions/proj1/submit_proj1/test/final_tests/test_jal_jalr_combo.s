# test_jal_jalr_combo.s
# Tests JAL followed by JALR
.text
.globl main
main:
    jal  x1, step1      # x1 = return addr
step1:
    la   x2, step2
    jalr x0, x2, 0      # jump via register
    addi x3, x0, 99    # should NOT run
step2:
    addi x4, x0, 1
    wfi
# Expected: x3=0, x4=1