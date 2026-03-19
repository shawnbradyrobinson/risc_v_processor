.data
    array_size: .word 12
    array: .word 65, 12, 10, 89, 11, 70, 67, 5, 9, 45, 90, 7

    temp: .space 2048   # 512 ints max

.text
.globl main

main:
    addi sp, sp, -4
    sw ra, 0(sp)
    
    la a0, array
    lw a1, array_size
    jal ra, sort

    lw ra, 0(sp)
    addi sp, sp, 4
    
    wfi

########################################################
# void sort(int* array, int size)
########################################################
.globl sort
sort:
    li t0, 1
    ble a1, t0, sort_ret   # if size <= 1 return

    addi sp, sp, -20
    sw ra, 16(sp)
    sw a0, 12(sp)
    sw a1, 8(sp)

    srli t0, a1, 1     # mid

    ####################################################
    # sort(left)
    ####################################################
    mv a1, t0
    jal ra, sort

    ####################################################
    # sort(right)
    ####################################################
    lw a0, 12(sp)
    lw a1, 8(sp)

    srli t0, a1, 1     # mid again
    slli t1, t0, 2
    add a0, a0, t1     # array + mid

    sub a1, a1, t0
    jal ra, sort

    ####################################################
    # merge
    ####################################################
    lw a0, 12(sp)
    lw a1, 8(sp)
    jal ra, merge

    lw ra, 16(sp)
    addi sp, sp, 20

sort_ret:
    ret

########################################################
# void merge(int* array, int size)
########################################################
merge:
    addi sp, sp, -24
    sw ra, 20(sp)
    sw s0, 16(sp)      # preserve s0
    sw a0, 12(sp)
    sw a1, 8(sp)

    srli s0, a1, 1     # s0 = mid (SAFE storage)

    li t0, 0           # i = 0
    mv t1, s0          # j = mid
    li t2, 0           # k = 0

    la t3, temp        # temp base

########################################################
# merge loop
########################################################
merge_loop:
    bge t0, s0, copy_right
    bge t1, a1, copy_left

    # left value -> t4
    slli t5, t0, 2
    add t5, a0, t5
    lw t4, 0(t5)

    # right value -> t6
    slli t5, t1, 2
    add t5, a0, t5
    lw t6, 0(t5)

    ble t4, t6, take_left

take_right:
    slli t5, t2, 2
    add t5, t3, t5
    sw t6, 0(t5)

    addi t1, t1, 1
    addi t2, t2, 1
    j merge_loop

take_left:
    slli t5, t2, 2
    add t5, t3, t5
    sw t4, 0(t5)

    addi t0, t0, 1
    addi t2, t2, 1
    j merge_loop

########################################################
# copy remaining left
########################################################
copy_left:
    bge t0, s0, copy_back

    slli t5, t0, 2
    add t5, a0, t5
    lw t4, 0(t5)

    slli t5, t2, 2
    add t5, t3, t5
    sw t4, 0(t5)

    addi t0, t0, 1
    addi t2, t2, 1
    j copy_left

########################################################
# copy remaining right
########################################################
copy_right:
    bge t1, a1, copy_back

    slli t5, t1, 2
    add t5, a0, t5
    lw t4, 0(t5)

    slli t5, t2, 2
    add t5, t3, t5
    sw t4, 0(t5)

    addi t1, t1, 1
    addi t2, t2, 1
    j copy_right

########################################################
# copy back to original array
########################################################
copy_back:
    li t0, 0

copy_back_loop:
    bge t0, a1, merge_done

    slli t5, t0, 2
    add t6, t3, t5
    lw t4, 0(t6)

    add t6, a0, t5
    sw t4, 0(t6)

    addi t0, t0, 1
    j copy_back_loop

merge_done:
    lw ra, 20(sp)
    lw s0, 16(sp)
    addi sp, sp, 24
    ret