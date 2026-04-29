# test_fwd_jalr.s
# Tests forwarding into JALR base address register
.text
.globl main
main:
    la   x1, target     # x1 = address of target
    jalr x0, x1, 0      # jump to target using forwarded x1
    addi x2, x0, 99    # should NOT execute
target:
    addi x3, x0, 1     # x3 = 1
    wfi
# Expected: x2=0, x3=1