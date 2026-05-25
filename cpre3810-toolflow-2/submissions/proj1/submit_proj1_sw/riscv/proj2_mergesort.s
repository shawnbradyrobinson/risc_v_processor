.data
array_size: .word 12
array:      .word 65, 12, 10, 89, 11, 70, 67, 5, 9, 45, 90, 7
temp:       .space 2048
.text
.globl main
main:
    lui  s0, 0x10010
    nop
    nop
    nop
    addi s0, s0, 4
    lui  t0, 0x10010
    nop
    nop
    nop
    addi t0, t0, 0
    addi s2, zero, 1
    nop
    nop
    nop
    lw   s1, 0(t0)
    nop
    nop
    nop
outer_loop:
    bge  s2, s1, done
    nop
    nop
    nop
    addi s3, zero, 0
merge_loop:
    nop
    nop
    nop
    bge  s3, s1, next_width
    nop
    nop
    nop
    add  t1, s3, s2
    nop
    nop
    nop
    add  t2, t1, s2
    nop
    nop
    nop
    blt  t1, s1, mid_ok
    nop
    nop
    nop
    addi t1, s1, 0
mid_ok:
    nop
    nop
    nop
    blt  t2, s1, right_ok
    nop
    nop
    nop
    addi t2, s1, 0
right_ok:
    nop
    nop
    nop
    bge  t1, t2, skip_merge
    nop
    nop
    nop
    slli t6, s1, 2
    nop
    nop
    nop
    add  t6, s0, t6
    nop
    nop
    nop
    addi t3, s3, 0
    nop
    nop
    nop
    addi t4, t1, 0
    nop
    nop
    nop
    addi t5, s3, 0
merge_inner:
    nop
    nop
    nop
    bge  t3, t1, copy_right
    nop
    nop
    nop
    bge  t4, t2, copy_left
    nop
    nop
    nop
    slli a0, t3, 2
    nop
    nop
    nop
    add  a0, s0, a0
    nop
    nop
    nop
    lw   a1, 0(a0)
    nop
    nop
    nop
    slli a2, t4, 2
    nop
    nop
    nop
    add  a2, s0, a2
    nop
    nop
    nop
    lw   a3, 0(a2)
    nop
    nop
    nop
    slli a4, t5, 2
    nop
    nop
    nop
    blt  a3, a1, take_right
    nop
    nop
    nop
take_left:
    add  a4, t6, a4
    nop
    nop
    nop
    addi t3, t3, 1
    nop
    nop
    nop
    addi t5, t5, 1
    nop
    nop
    nop
    sw   a1, 0(a4)
    beq  zero, zero, merge_inner
    nop
    nop
    nop
take_right:
    add  a4, t6, a4
    nop
    nop
    nop
    addi t4, t4, 1
    nop
    nop
    nop
    addi t5, t5, 1
    nop
    nop
    nop
    sw   a3, 0(a4)
    beq  zero, zero, merge_inner
    nop
    nop
    nop
copy_left:
    bge  t3, t1, copy_back
    nop
    nop
    nop
    slli a0, t3, 2
    nop
    nop
    nop
    add  a0, s0, a0
    nop
    nop
    nop
    lw   a1, 0(a0)
    nop
    nop
    nop
    slli a4, t5, 2
    nop
    nop
    nop
    add  a4, t6, a4
    nop
    nop
    nop
    sw   a1, 0(a4)
    nop
    nop
    nop
    addi t3, t3, 1
    nop
    nop
    nop
    addi t5, t5, 1
    beq  zero, zero, copy_left
    nop
    nop
    nop
copy_right:
    bge  t4, t2, copy_back
    nop
    nop
    nop
    slli a2, t4, 2
    nop
    nop
    nop
    add  a2, s0, a2
    nop
    nop
    nop
    lw   a3, 0(a2)
    nop
    nop
    nop
    slli a4, t5, 2
    nop
    nop
    nop
    add  a4, t6, a4
    nop
    nop
    nop
    sw   a3, 0(a4)
    nop
    nop
    nop
    addi t4, t4, 1
    nop
    nop
    nop
    addi t5, t5, 1
    beq  zero, zero, copy_right
    nop
    nop
    nop
copy_back:
    addi t3, s3, 0
copy_loop:
    nop
    nop
    nop
    bge  t3, t2, skip_merge
    nop
    nop
    nop
    slli a0, t3, 2
    nop
    nop
    nop
    add  a1, t6, a0
    nop
    nop
    nop
    add  a3, s0, a0
    nop
    nop
    nop
    lw   a2, 0(a1)
    nop
    nop
    nop
    sw   a2, 0(a3)
    nop
    nop
    nop
    addi t3, t3, 1
    beq  zero, zero, copy_loop
    nop
    nop
    nop
skip_merge:
    add  s3, s3, s2
    nop
    nop
    nop
    add  s3, s3, s2
    nop
    nop
    nop
    beq  zero, zero, merge_loop
    nop
    nop
    nop
next_width:
    slli s2, s2, 1
    nop
    nop
    nop
    beq  zero, zero, outer_loop
    nop
    nop
    nop
done:
    wfi
