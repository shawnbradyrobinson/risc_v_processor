

addi x25, zero, 0
addi x26, zero, 256
lw x1, 0(x25)
lw x2 4(x25)
add x1, x1, x2
sw x1, 0(x26)
lw x2, 8(x25)
add x1, x1, x2
sw x1, 4(x26) 
lw x2, 12(x25)
add x1, x1, x2
sw x1, 12(x26)
lw x2, 20(x25)
add x1, x1, x2
sw x1, 16(x26)
lw x2, 24(x25)
add x1, x1, x2
addi x27, zero, 512
sw x1, -4(x27)