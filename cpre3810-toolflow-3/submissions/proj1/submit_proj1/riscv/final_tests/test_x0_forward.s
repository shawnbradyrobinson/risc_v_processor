# test_x0_forward.s
# Tests that forwarding is suppressed when rd=x0
.text
.globl main
main:
    addi x0, x0, 99    # attempt to write x0 (should stay 0)
    addi x1, x0, 1     # x1 = 1 (x0 should NOT forward 99)
    wfi
# Expected: x0=0, x1=1