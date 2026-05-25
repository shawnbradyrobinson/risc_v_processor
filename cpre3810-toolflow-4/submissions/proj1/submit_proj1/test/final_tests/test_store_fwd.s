# test_store_fwd.s
# Tests that forwarded value is correctly used as store data
.text
.globl main
main:
    lui  s0, 0x10010    # base address
    addi x1, x0, 99    # x1 = 99
    sw   x1, 0(s0)      # store forwarded x1 (EX/MEM\u2192EX forward for rs2)
    lw   x2, 0(s0)      # x2 should be 99
    wfi
# Expected: x2=99