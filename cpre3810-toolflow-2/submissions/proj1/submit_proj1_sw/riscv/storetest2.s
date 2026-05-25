.data
    buf: .word 0, 0

.text
addi  x1, x0, 42
nop
nop
nop
lasw  x2, buf
nop
nop
nop
sw    x1, 0(x2)
nop
nop
nop
sw    x1, 4(x2)
nop
nop
nop
lw    x3, 0(x2)
nop
nop
nop
lw    x4, 4(x2)
nop
nop
nop
wfi