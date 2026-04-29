# test_loaduse_branch.s
# Load-use stall immediately before branch
.text
.globl main
main:
    lui  s0, 0x10010
    addi x1, x0, 5
    sw   x1, 0(s0)
    lw   x2, 0(s0)      # load x2=5
    beq  x2, x1, pass   # load-use stall then branch with forwarded value
    addi x3, x0, 99
pass:
    addi x4, x0, 1
    wfi
# Expected: x3=0, x4=1