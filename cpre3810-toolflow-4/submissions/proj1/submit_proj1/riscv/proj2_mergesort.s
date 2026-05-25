# Merge Sort - CPR E 3810 (FINAL FIXED)

.data
    array_size: .word 12
    array:      .word 65, 12, 10, 89, 11, 70, 67, 5, 9, 45, 90, 7
    temp:       .space 1024

.text
.globl main

main:
    # --- Setup stack ---
    lui  sp, 0x80000        
    addi sp, sp, -4         

    # --- Load array + size ---
    la   s0, array
    la   t0, array_size
    lw   s1, 0(t0)

    mv   a0, s0
    mv   a1, s1
    jal  ra, sort

    # ✅ Proper termination (NO fall-through)
    li   a7, 10
    ecall


########################################################
# sort(a0: addr, a1: size)
########################################################
sort:
    li   t0, 1
    ble  a1, t0, sort_done  

    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   a0, 8(sp)
    sw   a1, 4(sp)

    srli t0, a1, 1          # mid

    # --- sort(left) ---
    mv   a1, t0
    jal  ra, sort

    # --- sort(right) ---
    lw   a0, 8(sp)
    lw   a1, 4(sp)
    srli t0, a1, 1
    slli t1, t0, 2
    add  a0, a0, t1
    sub  a1, a1, t0
    jal  ra, sort

    # --- merge ---
    lw   a0, 8(sp)
    lw   a1, 4(sp)
    jal  ra, merge

    # restore
    lw   ra, 12(sp)
    addi sp, sp, 16

sort_done:
    ret


########################################################
# merge(a0: addr, a1: size)
########################################################
merge:
    addi sp, sp, -32
    sw   ra, 28(sp)
    sw   s0, 24(sp)
    sw   s1, 20(sp)
    sw   s2, 16(sp)
    sw   a0, 12(sp)
    sw   a1, 8(sp)

    srli s0, a1, 1      # mid
    mv   s2, a1         # size (stable)

    li   t0, 0          # i = 0
    mv   t1, s0         # j = mid
    li   t2, 0          # k = 0
    la   s1, temp       # temp buffer

merge_loop:
    bge  t0, s0, copy_right 
    bge  t1, s2, copy_left  

    # left[i]
    slli t5, t0, 2
    add  t5, a0, t5
    lw   t3, 0(t5)

    # right[j]
    slli t5, t1, 2
    add  t5, a0, t5
    lw   t4, 0(t5)

    ble  t3, t4, take_left

take_right:
    slli t5, t2, 2
    add  t5, s1, t5
    sw   t4, 0(t5)
    addi t1, t1, 1
    j    merge_inc_k

take_left:
    slli t5, t2, 2
    add  t5, s1, t5
    sw   t3, 0(t5)
    addi t0, t0, 1

merge_inc_k:
    addi t2, t2, 1
    j    merge_loop


copy_left:
    bge  t0, s0, copy_back
    slli t5, t0, 2
    add  t5, a0, t5
    lw   t3, 0(t5)
    slli t5, t2, 2
    add  t5, s1, t5
    sw   t3, 0(t5)
    addi t0, t0, 1
    addi t2, t2, 1
    j    copy_left


copy_right:
    bge  t1, s2, copy_back
    slli t5, t1, 2
    add  t5, a0, t5
    lw   t3, 0(t5)
    slli t5, t2, 2
    add  t5, s1, t5
    sw   t3, 0(t5)
    addi t1, t1, 1
    addi t2, t2, 1
    j    copy_right


copy_back:
    li   t0, 0

cb_loop:
    bge  t0, s2, merge_done
    slli t5, t0, 2
    add  t6, s1, t5
    lw   t3, 0(t6)
    add  t6, a0, t5
    sw   t3, 0(t6)
    addi t0, t0, 1
    j    cb_loop


merge_done:
    # ✅ restore arguments (important!)
    lw   a0, 12(sp)
    lw   a1, 8(sp)

    lw   ra, 28(sp)
    lw   s0, 24(sp)
    lw   s1, 20(sp)
    lw   s2, 16(sp)
    addi sp, sp, 32
    ret