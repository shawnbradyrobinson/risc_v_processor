lui  x3, 0x10010        # x3 = 0x10010000 (base of MMIO region)
addi x3, x3, 0x0010    # x3 = 0x10010010 (display control register)
addi x4, x0, 60        # x4 = 60
sw   x4, 0(x3)         # write to MMIO — initializes RARS display
wfi
