.text
_start:
    lui  sp, 0x80000
    addi sp, sp, -4
    
    # Manually calculate the address of func1
    # If your hardware requires shifting, this will behave differently than a label
    auipc t0, 0            # t0 = current PC
    addi  t0, t0, 16       # Manually point to func1 (approx 4 instructions away)
    jalr  ra, 0(t0)        # Jump to register
    
    wfi
