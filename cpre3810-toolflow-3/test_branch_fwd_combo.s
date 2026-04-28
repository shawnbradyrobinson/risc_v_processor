# test_branch_fwd_combo.s
# Forward into branch operands AND take branch
.text
.globl main
main:
    addi x1, x0, 10
    addi x2, x1, 0     # x2=10, forwarded from EX/MEM
    beq  x1, x2, pass  # branch using forwarded values
    addi x3, x0, 99
pass:
    addi x4, x0, 1
    wfi
# Expected: x3=0, x4=1