# test_double_fwd.s
# Tests simultaneous forwarding to both rs1 and rs2
.text
.globl main
main:
    addi x1, x0, 10    # x1 = 10
    addi x2, x0, 5     # x2 = 5
    add  x3, x1, x2    # x3 = 15 (x1 from EX/MEM, x2 from MEM/WB simultaneously)
    wfi
# Expected: x1=10, x2=5, x3=15