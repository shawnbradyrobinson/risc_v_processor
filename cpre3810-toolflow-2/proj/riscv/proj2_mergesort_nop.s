# Merge Sort - CPR E 3810 (PIPELINE SAFE)

.data
    array_size: .word 12
    array:      .word 65, 12, 10, 89, 11, 70, 67, 5, 9, 45, 90, 7
    temp:       .space 1024

.text
.globl main

main:
    lui  sp, 0x80000
    nop
    nop
    addi sp, sp, -4

    la   s0, array
    nop
    nop

    la   t0, array_size
    nop
    nop

    lw   s1, 0(t0)
    nop
    nop

    mv   a0, s0
    mv   a1, s1

    jal  ra, sort
    nop
    nop

    li   a7, 10
    nop
    nop
    wfi


########################################################
# sort
########################################################
sort:
    li   t0, 1
    nop
    nop
    ble  a1, t0, sort_done
    nop
    nop

    addi sp, sp, -16
    nop
    nop
    sw   ra, 12(sp)
    sw   a0, 8(sp)
    sw   a1, 4(sp)

    addi t0, a1, -1
   srli t0, a1, 1       # mid = size / 2
	bnez t0, mid_ok
	nop
	nop
	li   t0, 1           # force mid >= 1
	mid_ok:
	nop
	nop

    # sort(left)
    mv   a1, t0
    nop
    nop
    jal  ra, sort
    nop
    nop

    # sort(right)
    lw   a0, 8(sp)
    lw   a1, 4(sp)
    nop
    nop

    srli t0, a1, 1
    nop
    nop

    slli t1, t0, 2
    nop
    nop

    add  a0, a0, t1
    sub  a1, a1, t0
    nop
    nop

    jal  ra, sort
    nop
    nop

    # merge
    lw   a0, 8(sp)
    lw   a1, 4(sp)
    nop
    nop

    jal  ra, merge
    nop
    nop

    lw   ra, 12(sp)
    nop
    nop
    addi sp, sp, 16
    nop
    nop

sort_done:
    ret
    nop
    nop


########################################################
# merge
########################################################
merge:
    addi sp, sp, -32
    nop
    nop
    sw   ra, 28(sp)
    sw   s0, 24(sp)
    sw   s1, 20(sp)
    sw   s2, 16(sp)
    sw   a0, 12(sp)
    sw   a1, 8(sp)

    srli s0, a1, 1
    mv   s2, a1
    nop
    nop

    li   t0, 0
    mv   t1, s0
    li   t2, 0

    la   s1, temp
    nop
    nop


merge_loop:
    bge  t0, s0, copy_right
    nop
    nop

    bge  t1, s2, copy_left
    nop
    nop

    # left[i]
    slli t5, t0, 2
    nop
    nop
    add  t5, a0, t5
    nop
    nop
    lw   t3, 0(t5)

    # right[j]
    slli t5, t1, 2
    nop
    nop
    add  t5, a0, t5
    nop
    nop
    lw   t4, 0(t5)
    nop
    nop

    ble  t3, t4, take_left
    nop
    nop


take_right:
    slli t5, t2, 2
    nop
    nop
    add  t5, s1, t5
    nop
    nop
    sw   t4, 0(t5)

    addi t1, t1, 1
    addi t2, t2, 1

    j    merge_loop
    nop
    nop


take_left:
    slli t5, t2, 2
    nop
    nop
    add  t5, s1, t5
    nop
    nop
    sw   t3, 0(t5)

    addi t0, t0, 1
    addi t2, t2, 1

    j    merge_loop
    nop
    nop


copy_left:
    bge  t0, s0, copy_back
    nop
    nop

    slli t5, t0, 2
    nop
    nop
    add  t5, a0, t5
    nop
    nop
    lw   t3, 0(t5)

    slli t5, t2, 2
    nop
    nop
    add  t5, s1, t5
    nop
    nop
    sw   t3, 0(t5)

    addi t0, t0, 1
    addi t2, t2, 1

    j    copy_left
    nop
    nop


copy_right:
    bge  t1, s2, copy_back
    nop
    nop

    slli t5, t1, 2
    nop
    nop
    add  t5, a0, t5
    nop
    nop
    lw   t3, 0(t5)

    slli t5, t2, 2
    nop
    nop
    add  t5, s1, t5
    nop
    nop
    sw   t3, 0(t5)

    addi t1, t1, 1
    addi t2, t2, 1

    j    copy_right
    nop
    nop


copy_back:
    li   t0, 0
    nop
    nop

cb_loop:
    bge  t0, s2, merge_done
    nop
    nop

    slli t5, t0, 2
    nop
    nop
    add  t6, s1, t5
    nop
    nop
    lw   t3, 0(t6)

    add  t6, a0, t5
    nop
    nop
    sw   t3, 0(t6)

    addi t0, t0, 1

    j    cb_loop
    nop
    nop


merge_done:
    lw   a0, 12(sp)
    lw   a1, 8(sp)
    lw   ra, 28(sp)
    lw   s0, 24(sp)
    lw   s1, 20(sp)
    lw   s2, 16(sp)
    nop
    nop
    addi sp, sp, 32

    ret
    nop
    nop