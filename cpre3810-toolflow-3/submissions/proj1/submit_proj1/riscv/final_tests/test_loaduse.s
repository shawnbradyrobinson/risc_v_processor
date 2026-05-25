# test_loaduse.s
# Tests load-use hazard detection and stall insertion
.text
.globl main
main:
    lui  s0, 0x10010    # base address
    addi x1, x0, 42    # x1 = 42
    sw   x1, 0(s0)      # store 42 to memory
    lw   x2, 0(s0)      # x2 = 42 (load)
    addi x3, x2, 1      # x3 = 43 (load-use hazard: needs x2 from load)
    wfi
# Expected: x2=42, x3=43