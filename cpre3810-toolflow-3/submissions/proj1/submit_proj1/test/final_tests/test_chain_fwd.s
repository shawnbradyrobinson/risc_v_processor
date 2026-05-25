# test_chain_fwd.s
# Tests a chain where each instruction depends on the previous
.text
.globl main
main:
    addi x1, x0, 1     # x1 = 1
    addi x2, x1, 1     # x2 = 2  (EX/MEM\u2192EX)
    addi x3, x2, 1     # x3 = 3  (EX/MEM\u2192EX)
    addi x4, x3, 1     # x4 = 4  (EX/MEM\u2192EX)
    addi x5, x4, 1     # x5 = 5  (EX/MEM\u2192EX)
    wfi
# Expected: x1=1, x2=2, x3=3, x4=4, x5=5