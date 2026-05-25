# test_loaduse_fwd.s
# Tests load-use stall followed immediately by forwarding
.text
.globl main
main:
    lui  s0, 0x10010
    addi x1, x0, 7
    sw   x1, 0(s0)
    lw   x2, 0(s0)      # load x2 = 7
    add  x3, x2, x2     # load-use stall, then x2 forwarded to both rs1 and rs2
    wfi
# Expected: x2=7, x3=14