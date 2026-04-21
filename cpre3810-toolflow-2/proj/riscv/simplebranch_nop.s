main:
	ori s0, x0, 0x123
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	j skip
	nop
	nop
	nop
	nop
	nop
	nop
	li s0, 0xffffffff
	nop
	nop
	nop
	nop
	nop
	nop
	nop

skip:
	nop
	nop
	nop
	nop
	nop
	nop
	ori s1, x0, 0x123
	nop
	nop
	nop
	nop
	nop
	nop
	beq s0, s1, skip2
	nop
	nop
	nop
	nop
	nop
	nop
	li s0, 0xffffffff
	nop
	nop
	nop
	nop
	nop
	nop

skip2:
	nop
	nop
	nop
	nop
	nop
	nop
	jal fun
	nop
	nop
	nop
	nop
	nop
	nop
	ori s3, x0, 0x123
	nop
	nop
	nop
	nop
	nop
	nop
	beq s0, x0, exit
	nop
	nop
	nop
	nop
	nop
	nop
	ori s4, x0, 0x123
	nop
	nop
	nop
	nop
	nop
	nop
	j exit
	nop
	nop
	nop
	nop
	nop
	nop
fun:
	ori s2, x0, 0x123
	nop
	nop
	nop
	nop
	nop
	nop
	jr ra
	nop
	nop
	nop
	nop
	nop
	nop
exit:
	wfi

