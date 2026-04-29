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
    nop
    nop
    nop   
    addi sp, sp, -4         
    nop
    nop
    nop  
    # --- Load array + size ---
    lasw   s0, array
    lasw   t0, array_size
    lw   s1, 0(t0)
    nop
    nop
    nop  
    mv   a0, s0
    nop
    nop
    nop  
    mv   a1, s1
    nop
    nop
    nop  
    jal  ra, sort
    nop
    nop
    nop  

    # ✅ Proper termination (NO fall-through)
    li   a7, 10
    nop
    nop
    nop  
    ecall


########################################################
# sort(a0: addr, a1: size)
########################################################
sort:
    li   t0, 1
    nop
    nop
    nop  
    ble  a1, t0, sort_done  
    nop
    nop
    nop  
    addi sp, sp, -16
     nop
    nop
    nop  
    sw   ra, 12(sp)
     nop
    nop
    nop  
    sw   a0, 8(sp)
     nop
    nop
    nop  
    sw   a1, 4(sp)
    nop
    nop
    nop  
    srli t0, a1, 1          # mid
    nop
    nop
    nop  
    # --- sort(left) ---
    mv   a1, t0
     nop
    nop
    nop  
    jal  ra, sort
    nop
    nop
    nop  
    # --- sort(right) ---
    lw   a0, 8(sp)
     nop
    nop
    nop  
    lw   a1, 4(sp)
     nop
    nop
    nop  
    srli t0, a1, 1
     nop
    nop
    nop  
    slli t1, t0, 2
     nop
    nop
    nop  
    add  a0, a0, t1
     nop
    nop
    nop  
    sub  a1, a1, t0
     nop
    nop
    nop  
    jal  ra, sort
    nop
    nop
    nop  
    # --- merge ---
    lw   a0, 8(sp)
     nop
    nop
    nop  
    lw   a1, 4(sp)
     nop
    nop
    nop  
    jal  ra, merge
    nop
    nop
    nop  
    # restore
    lw   ra, 12(sp)
     nop
    nop
    nop  
    addi sp, sp, 16
    nop
    nop
    nop  
sort_done:
    ret


########################################################
# merge(a0: addr, a1: size)
########################################################
merge:
    addi sp, sp, -32
    sw   ra, 28(sp)
     nop
    nop
    nop  
    sw   s0, 24(sp)
     nop
    nop
    nop  
    sw   s1, 20(sp)
     nop
    nop
    nop  
    sw   s2, 16(sp)
     nop
    nop
    nop  
    sw   a0, 12(sp)
     nop
    nop
    nop  
    sw   a1, 8(sp)
    nop
    nop
    nop  
    srli s0, a1, 1      # mid
     nop
    nop
    nop  
    mv   s2, a1         # size (stable)
    nop
    nop
    nop  
    li   t0, 0          # i = 0
     nop
    nop
    nop  
    mv   t1, s0         # j = mid
     nop
    nop
    nop  
    li   t2, 0          # k = 0
     nop
    nop
    nop  
    lasw   s1, temp       # temp buffer

merge_loop:
    bge  t0, s0, copy_right 
    nop
    nop
    nop  
    bge  t1, s2, copy_left  
    nop
    nop
    nop  
    # left[i]
    slli t5, t0, 2
    nop
    nop
    nop  
    add  t5, a0, t5
        nop
    nop
    nop  
    lw   t3, 0(t5)
    nop
    nop
    nop  
    # right[j]
    slli t5, t1, 2
        nop
    nop
    nop  
    add  t5, a0, t5
    nop
    nop
    nop      
    lw   t4, 0(t5)
    nop
    nop
    nop  
    ble  t3, t4, take_left
    nop
    nop
    nop  
take_right:
    slli t5, t2, 2
        nop
    nop
    nop  
    add  t5, s1, t5
        nop
    nop
    nop  
    sw   t4, 0(t5)
        nop
    nop
    nop  
    addi t1, t1, 1
        nop
    nop
    nop  
    j    merge_inc_k
    nop
    nop
    nop  
take_left:
    slli t5, t2, 2
        nop
    nop
    nop  
    add  t5, s1, t5
        nop
    nop
    nop  
    sw   t3, 0(t5)
        nop
    nop
    nop  
    addi t0, t0, 1
    nop
    nop
    nop  
merge_inc_k:
    addi t2, t2, 1
        nop
    nop
    nop  
    j    merge_loop
    nop
    nop
    nop  

copy_left:
    bge  t0, s0, copy_back
        nop
    nop
    nop  
    slli t5, t0, 2
        nop
    nop
    nop  
    add  t5, a0, t5
        nop
    nop
    nop  
    lw   t3, 0(t5)
        nop
    nop
    nop  
    slli t5, t2, 2
        nop
    nop
    nop  
    add  t5, s1, t5
        nop
    nop
    nop  
    sw   t3, 0(t5)
        nop
    nop
    nop  
    addi t0, t0, 1
        nop
    nop
    nop  
    addi t2, t2, 1
        nop
    nop
    nop  
    j    copy_left
    nop
    nop
    nop  

copy_right:
    bge  t1, s2, copy_back
        nop
    nop
    nop  
    slli t5, t1, 2
        nop
    nop
    nop  
    add  t5, a0, t5
        nop
    nop
    nop  
    lw   t3, 0(t5)
        nop
    nop
    nop  
    slli t5, t2, 2
        nop
    nop
    nop  
    add  t5, s1, t5
        nop
    nop
    nop  
    sw   t3, 0(t5)
        nop
    nop
    nop  
    addi t1, t1, 1
        nop
    nop
    nop  
    addi t2, t2, 1
        nop
    nop
    nop  
    j    copy_right
    nop
    nop
    nop  

copy_back:
    li   t0, 0
    nop
    nop
    nop  
cb_loop:
    bge  t0, s2, merge_done
        nop
    nop
    nop  
    slli t5, t0, 2
        nop
    nop
    nop  
    add  t6, s1, t5
        nop
    nop
    nop  
    lw   t3, 0(t6)
        nop
    nop
    nop  
    add  t6, a0, t5
        nop
    nop
    nop  
    sw   t3, 0(t6)
        nop
    nop
    nop  
    addi t0, t0, 1
        nop
    nop
    nop  
    j    cb_loop
    nop
    nop
    nop  

merge_done:
    # ✅ restore arguments (important!)
    lw   a0, 12(sp)
        nop
    nop
    nop  
    lw   a1, 8(sp)
    nop
    nop
    nop  
    lw   ra, 28(sp)
        nop
    nop
    nop  
    lw   s0, 24(sp)
        nop
    nop
    nop  
    lw   s1, 20(sp)
        nop
    nop
    nop  
    lw   s2, 16(sp)
        nop
    nop
    nop  
    addi sp, sp, 32
        nop
    nop
    nop  
    ret
