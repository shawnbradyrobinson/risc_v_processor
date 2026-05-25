.data
    buf: .word 0, 0, 0

.text
addi  x25, x0, 0x5A
nop
nop
nop
lui   x31, 0x10010
nop
nop
nop
sw    x25, 0(x31)
nop
nop
nop
lw    x26, 0(x31)
nop
nop
nop
wfi