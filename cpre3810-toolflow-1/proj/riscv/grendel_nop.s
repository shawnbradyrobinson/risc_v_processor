#
# Topological sort using an adjacency matrix. Maximum 4 nodes.
# 
# Software-scheduled for 5-stage RISC-V pipeline:
#   NO forwarding, NO hazard detection, NO stalling
#
# Rules:
#   DATA:    3 NOPs between producer and consumer (no register file bypass)
#   CONTROL: 2 NOPs after every branch/jump (delay slots)
#   LOAD:    3 NOPs between load and consumer
#   lasw:    expands to lui/nop/nop/ori -- need 3 more NOPs after before use
#   jr ra:   2 NOPs after (delay slots)
#
# Expected output: res = [3, 0, 2, 1]
#

.data
res:
	.word -1-1-1-1
nodes:
        .byte   97
        .byte   98
        .byte   99
        .byte   100
adjacencymatrix:
        .word   6
        .word   0
        .word   0
        .word   3
visited:
	.byte 0 0 0 0
res_idx:
        .word   3
.text
        lui  sp, 0x10011        # sp upper
       # addi sp, sp, 0          # sp = 0x10011000; sp ready
        nop
        nop
        nop
        li   fp, 0              # fp = 0 (single insn, addi x0 -- safe)
        nop
        nop
        nop
        lasw ra, pump           # ra = &pump (lui/nop/nop/ori internally)
        nop
        nop
        nop
        j    main               # jump; ra ready
        nop
        nop
pump:
        j end
        nop
        nop
        #ebreak


main:
        addi sp, sp, -40        # sp -= 40
        nop
        nop
        nop
        sw   ra, 36(sp)         # sp ready
        sw   fp, 32(sp)         # independent
        nop
        nop
        add  fp, sp, x0         # fp = sp; sp ready (3 nops + 2 sw = 5 insns)
        nop
        nop
        nop
        sw   x0, 24(sp)         # fp ready
        j    main_loop_control
        nop
        nop

main_loop_body:
        lw   t4, 24(fp)         # t4 = loop counter
        nop
        nop
        nop
        lasw ra, trucks         # ra = &trucks; t4 ready
        nop
        nop
        nop
        j    is_visited         # ra ready
        nop
        nop
trucks:
        xori t2, t2, 1          # t2 ^= 1
        nop
        nop
        nop
        andi t2, t2, 0xff       # t2 &= 0xff; t2 ready
        nop
        nop
        nop
        beq  t2, x0, kick       # t2 ready
        nop
        nop
        lw   t4, 24(fp)         # t4 = loop counter
        nop
        nop
        nop
        lasw ra, billowy        # ra = &billowy; t4 ready
        nop
        nop
        nop
        j    topsort            # ra ready
        nop
        nop
billowy:

kick:
        lw   t2, 24(fp)         # t2 = counter
        nop
        nop
        nop
        addi t2, t2, 1          # t2++; t2 ready
        nop
        nop
        nop
        sw   t2, 24(fp)         # store; t2 ready
main_loop_control:
        lw   t2, 24(fp)         # t2 = counter
        nop
        nop
        nop
        slti t2, t2, 4          # t2 = (counter < 4); t2 ready
        nop
        nop
        nop
        beq  t2, x0, hew        # t2 ready
        nop
        nop
        j    main_loop_body
        nop
        nop
hew:
        sw   x0, 28(fp)
        j    welcome
        nop
        nop

wave:
        lw   t2, 28(fp)
        nop
        nop
        nop
        addi t2, t2, 1          # t2 ready
        nop
        nop
        nop
        sw   t2, 28(fp)         # t2 ready
welcome:
        lw   t2, 28(fp)
        nop
        nop
        nop
        slti t2, t2, 4          # t2 ready
        nop
        nop
        nop
        xori t2, t2, 1          # t2 ready
        nop
        nop
        nop
        beq  t2, x0, wave       # t2 ready
        nop
        nop
        mv   t2, x0
        mv   sp, fp             # sp = fp (independent)
        nop
        nop
        nop
        lw   ra, 36(sp)         # sp ready
        lw   fp, 32(sp)         # independent
        nop
        nop
        nop
        addi sp, sp, 40         # ra/fp ready (3 nops + lw fp = enough for ra)
        nop
        nop
        jr   ra                 # ra ready (addi + 2 nops = 3 insns since lw ra)
        nop
        nop

interest:
        lw   t4, 24(fp)
        nop
        nop
        nop
        lasw ra, new            # t4 ready
        nop
        nop
        nop
        j    is_visited         # ra ready
        nop
        nop
new:
        xori t2, t2, 1
        nop
        nop
        nop
        andi t2, t2, 0x0ff      # t2 ready
        nop
        nop
        nop
        beq  t2, x0, tasteful   # t2 ready
        nop
        nop
        lw   t4, 24(fp)
        nop
        nop
        nop
        lasw ra, partner        # t4 ready
        nop
        nop
        nop
        j    topsort            # ra ready
        nop
        nop
partner:

tasteful:
        addi t2, fp, 28         # t2 = fp+28
        nop
        nop
        nop
        mv   t4, t2             # t4 = t2; t2 ready
        nop
        nop
        nop
        lasw ra, badge          # t4 ready
        nop
        nop
        nop
        j    next_edge          # ra ready
        nop
        nop
badge:
        sw   t2, 24(fp)         # t2 still valid from tasteful

turkey:
        lw   t3, 24(fp)
        nop
        nop
        nop
        li   t2, -1             # independent single insn
        nop
        nop
        beq  t3, t2, telling    # t3 ready (3 nops since lw); t2 ready
        nop
        nop
        j    interest
        nop
        nop
telling:
        lasw t2, res_idx
        nop
        nop
        nop
        lw   t2, 0(t2)          # t2 ready
        nop
        nop
        nop
        addi t4, t2, -1         # t4 = idx-1; t2 ready
        nop
        nop
        nop
        lasw t3, res_idx        # t4 ready
        nop
        nop
        nop
        sw   t4, 0(t3)          # t3 ready; t4 ready
        lasw t4, res            # t4 = &res (independent)
        nop
        nop
        nop
        slli t3, t2, 2          # t3 = t2*4; t2 still valid; t4 ready
        nop
        nop
        nop
        srli t3, t3, 1          # t3 >>= 1; t3 ready
        nop
        nop
        nop
        srai t3, t3, 1          # t3 >>= 1 arithmetic; t3 ready
        nop
        nop
        nop
        slli t3, t3, 2          # t3 <<= 2; t3 ready
        nop
        nop
        nop
        xor  t6, ra, t2         # t6 = ra^t2 (does nothing useful)
        nop
        nop
        nop
        or   t6, ra, t2         # t6 = ra|t2; t6 ready
        nop
        nop
        nop
        neg  t6, t6             # t6 = -t6; t6 ready
        nop
        nop
        nop
        lasw t2, res            # t2 = &res
        nop
        nop
        nop
        lui  a1, 0x10           # a1 upper for 0x0000ffff
        nop
        nop
        nop
        addi a1, a1, -1         # a1 = 0x0000ffff; a1 ready
        nop
        nop
        nop
        and  t6, t2, a1         # t6 = t2 & 0xffff; t2,a1 ready
        nop
        nop
        nop
        add  t2, t4, t6         # t2 = &res + offset; t4,t6 ready
        nop
        nop
        nop
        add  t2, t3, t2         # t2 = final addr; t3,t2 ready
        nop
        nop
        nop
        lw   t3, 48(fp)         # t3 = node value; t2 ready
        nop
        nop
        nop
        sw   t3, 0(t2)          # store; t3,t2 ready
        mv   sp, fp             # independent
        nop
        nop
        nop
        lw   ra, 44(sp)         # sp ready
        lw   fp, 40(sp)         # independent
        nop
        nop
        nop
        addi sp, sp, 48         # ra/fp ready
        nop
        nop
        jr   ra                 # ra ready (addi + 2 nops = 3 insns)
        nop
        nop

topsort:
        addi sp, sp, -48
        nop
        nop
        nop
        sw   ra, 44(sp)         # sp ready
        sw   fp, 40(sp)         # independent
        nop
        nop
        nop
        mv   fp, sp             # fp = sp; sp ready (3 nops + 2 sw = 5 insns)
        nop
        nop
        nop
        sw   t4, 48(fp)         # fp ready
        lw   t4, 48(fp)         # independent load
        nop
        nop
        nop
        lasw ra, verse          # t4 ready
        nop
        nop
        nop
        j    mark_visited       # ra ready
        nop
        nop
verse:
        addi t2, fp, 28
        nop
        nop
        nop
        lw   t5, 48(fp)         # independent; t2 ready
        nop
        nop
        nop
        mv   t4, t2             # t4 = t2; t2 ready; t5 ready (3 nops since lw)
        nop
        nop
        nop
        lasw ra, joyous         # t4 ready
        nop
        nop
        nop
        j    iterate_edges      # ra ready
        nop
        nop
joyous:
        addi t2, fp, 28
        nop
        nop
        nop
        mv   t4, t2             # t2 ready
        nop
        nop
        nop
        lasw ra, whispering     # t4 ready
        nop
        nop
        nop
        j    next_edge          # ra ready
        nop
        nop
whispering:
        sw   t2, 24(fp)
        j    turkey
        nop
        nop

iterate_edges:
        addi sp, sp, -24
        nop
        nop
        nop
        sw   fp, 20(sp)         # sp ready
        nop
        nop
        nop
        mv   fp, sp             # fp = sp; sp ready
        nop
        nop
        nop
        sub  t6, fp, sp         # does nothing useful; fp ready
        sw   t4, 24(fp)         # independent
        sw   t5, 28(fp)         # independent
        lw   t2, 28(fp)         # independent load
        nop
        nop
        nop
        sw   t2, 8(fp)          # t2 ready
        sw   x0, 12(fp)         # independent
        lw   t2, 24(fp)         # independent load
        lw   t4, 8(fp)          # independent load
        lw   t3, 12(fp)         # independent load
        nop
        nop
        nop
        sw   t4, 0(t2)          # t2,t4 ready (3 nops since lw t2/t4)
        sw   t3, 4(t2)          # t3 ready; t2 ready
        lw   t2, 24(fp)         # independent
        nop
        nop
        nop
        mv   sp, fp             # t2 ready; independent
        nop
        nop
        nop
        lw   fp, 20(sp)         # sp ready
        nop
        nop
        nop
        addi sp, sp, 24         # fp ready
        nop
        nop
        jr   ra                 # sp ready; ra valid (never changed here)
        nop
        nop

next_edge:
        addi sp, sp, -32
        nop
        nop
        nop
        sw   ra, 28(sp)         # sp ready
        sw   fp, 24(sp)         # independent
        nop
        nop
        nop
        add  fp, x0, sp         # fp = sp; sp ready
        nop
        nop
        nop
        sw   t4, 32(fp)         # fp ready
        j    waggish
        nop
        nop

snail:
        lw   t2, 32(fp)
        nop
        nop
        nop
        lw   t3, 0(t2)          # t2 ready
        nop
        nop
        nop
        lw   t2, 32(fp)         # independent reload
        nop
        nop
        nop
        lw   t2, 4(t2)          # t2 ready
        nop
        nop
        nop
        mv   t5, t2             # t2 ready
        mv   t4, t3             # t3 ready (3 nops + lw t2 = 4 insns since lw t3)
        nop
        nop
        nop
        lasw ra, induce         # t5,t4 ready
        nop
        nop
        nop
        j    has_edge           # ra ready
        nop
        nop
induce:
        beq  t2, x0, quarter    # t2 valid from snail path
        nop
        nop
        lw   t2, 32(fp)
        nop
        nop
        nop
        lw   t2, 4(t2)          # t2 ready
        nop
        nop
        nop
        addi t4, t2, 1          # t2 ready
        nop
        nop
        nop
        lw   t3, 32(fp)         # independent
        nop
        nop
        nop
        sw   t4, 4(t3)          # t3,t4 ready
        j    cynical
        nop
        nop

quarter:
        lw   t2, 32(fp)
        nop
        nop
        nop
        lw   t2, 4(t2)          # t2 ready
        nop
        nop
        nop
        addi t3, t2, 1          # t2 ready
        nop
        nop
        nop
        lw   t2, 32(fp)         # independent
        nop
        nop
        nop
        sw   t3, 4(t2)          # t2,t3 ready

waggish:
        lw   t2, 32(fp)
        nop
        nop
        nop
        lw   t2, 4(t2)          # t2 ready
        nop
        nop
        nop
        slti t2, t2, 4          # t2 ready
        nop
        nop
        nop
        beq  t2, x0, mark       # t2 ready
        nop
        nop
        j    snail
        nop
        nop
mark:
        li   t2, -1             # single insn safe

cynical:
        mv   sp, fp
        nop
        nop
        nop
        lw   ra, 28(sp)         # sp ready
        lw   fp, 24(sp)         # independent
        nop
        nop
        nop
        addi sp, sp, 32         # ra/fp ready
        nop
        nop
        jr   ra                 # ra ready (addi + 2 nops = 3 insns)
        nop
        nop

has_edge:
        addi sp, sp, -32
        nop
        nop
        nop
        sw   fp, 28(sp)         # sp ready
        nop
        nop
        nop
        mv   fp, sp             # fp = sp; sp ready
        nop
        nop
        nop
        sw   t4, 32(fp)         # fp ready
        sw   t5, 36(fp)         # independent
        lasw t2, adjacencymatrix # independent
        nop
        nop
        nop
        lw   t3, 32(fp)         # t2 ready
        nop
        nop
        nop
        slli t3, t3, 2          # t3 ready
        nop
        nop
        nop
        add  t2, t3, t2         # t3,t2 ready
        nop
        nop
        nop
        lw   t2, 0(t2)          # t2 ready
        nop
        nop
        nop
        sw   t2, 16(fp)         # t2 ready
        li   t2, 1              # independent single insn
        nop
        nop
        nop
        sw   t2, 8(fp)          # t2 ready
        sw   x0, 12(fp)         # independent
        j    measley
        nop
        nop

look:
        lw   t2, 8(fp)
        nop
        nop
        nop
        slli t2, t2, 1          # t2 ready
        nop
        nop
        nop
        sw   t2, 8(fp)          # t2 ready
        lw   t2, 12(fp)         # independent
        nop
        nop
        nop
        addi t2, t2, 1          # t2 ready
        nop
        nop
        nop
        sw   t2, 12(fp)         # t2 ready
measley:
        lw   t3, 12(fp)
        lw   t2, 36(fp)         # independent
        nop
        nop
        nop
        slt  t2, t3, t2         # t3,t2 ready (3 nops since both lw)
        nop
        nop
        nop
        beq  t2, x0, experience # t2 ready
        nop
        nop
        j    look
        nop
        nop
experience:
        lw   t3, 8(fp)
        lw   t2, 16(fp)         # independent
        nop
        nop
        nop
        and  t2, t3, t2         # t3,t2 ready
        nop
        nop
        nop
        slt  t2, x0, t2         # t2 ready
        nop
        nop
        nop
        andi t2, t2, 0xff       # t2 ready
        nop
        nop
        nop
        mv   sp, fp             # independent
        nop
        nop
        nop
        lw   fp, 28(sp)         # sp ready
        nop
        nop
        nop
        addi sp, sp, 32         # fp ready
        nop
        nop
        jr   ra                 # ra valid (never changed in has_edge)
        nop
        nop

mark_visited:
        addi sp, sp, -32
        nop
        nop
        nop
        sw   fp, 28(sp)         # sp ready
        nop
        nop
        nop
        mv   fp, sp             # fp = sp
        nop
        nop
        nop
        sw   t4, 32(fp)         # fp ready
        li   t2, 1              # independent single insn
        nop
        nop
        nop
        sw   t2, 8(fp)          # t2 ready
        sw   x0, 12(fp)         # independent
        j    recast
        nop
        nop

example:
        lw   t2, 8(fp)
        nop
        nop
        nop
        slli t2, t2, 8          # t2 ready
        nop
        nop
        nop
        sw   t2, 8(fp)          # t2 ready
        lw   t2, 12(fp)         # independent
        nop
        nop
        nop
        addi t2, t2, 1          # t2 ready
        nop
        nop
        nop
        sw   t2, 12(fp)         # t2 ready
recast:
        lw   t3, 12(fp)
        lw   t2, 32(fp)         # independent
        nop
        nop
        nop
        slt  t2, t3, t2         # t3,t2 ready
        nop
        nop
        nop
        beq  t2, x0, pat        # t2 ready
        nop
        nop
        j    example
        nop
        nop
pat:
        lasw t2, visited
        nop
        nop
        nop
        sw   t2, 16(fp)         # t2 ready
        lw   t2, 16(fp)         # independent reload
        nop
        nop
        nop
        lw   t3, 0(t2)          # t2 ready
        nop
        nop
        nop
        lw   t2, 8(fp)          # independent
        nop
        nop
        nop
        or   t3, t3, t2         # t3,t2 ready
        nop
        nop
        nop
        lw   t2, 16(fp)         # independent
        nop
        nop
        nop
        sw   t3, 0(t2)          # t3,t2 ready
        mv   sp, fp             # independent
        nop
        nop
        nop
        lw   fp, 28(sp)         # sp ready
        nop
        nop
        nop
        addi sp, sp, 32         # fp ready
        nop
        nop
        jr   ra                 # ra valid
        nop
        nop

is_visited:
        addi sp, sp, -32
        nop
        nop
        nop
        sw   fp, 28(sp)         # sp ready
        nop
        nop
        nop
        mv   fp, sp             # fp = sp
        nop
        nop
        nop
        sw   t4, 32(fp)         # fp ready
        ori  t2, x0, 1          # independent single insn
        nop
        nop
        nop
        sw   t2, 8(fp)          # t2 ready
        sw   x0, 12(fp)         # independent
        j    evasive
        nop
        nop

justify:
        lw   t2, 8(fp)
        nop
        nop
        nop
        slli t2, t2, 8          # t2 ready
        nop
        nop
        nop
        sw   t2, 8(fp)          # t2 ready
        lw   t2, 12(fp)         # independent
        nop
        nop
        nop
        addi t2, t2, 1          # t2 ready
        nop
        nop
        nop
        sw   t2, 12(fp)         # t2 ready
evasive:
        lw   t3, 12(fp)
        lw   t2, 32(fp)         # independent
        nop
        nop
        nop
        slt  t2, t3, t2         # t3,t2 ready
        nop
        nop
        nop
        beq  t2, x0, representative # t2 ready
        nop
        nop
        j    justify
        nop
        nop
representative:
        lasw t2, visited
        nop
        nop
        nop
        lw   t2, 0(t2)          # t2 ready
        nop
        nop
        nop
        sw   t2, 16(fp)         # t2 ready
        lw   t3, 16(fp)         # independent reload
        nop
        nop
        nop
        lw   t2, 8(fp)          # independent
        nop
        nop
        nop
        and  t2, t3, t2         # t3,t2 ready
        nop
        nop
        nop
        slt  t2, x0, t2         # t2 ready
        nop
        nop
        nop
        andi t2, t2, 0xff       # t2 ready
        nop
        nop
        nop
        mv   sp, fp             # independent
        nop
        nop
        nop
        lw   fp, 28(sp)         # sp ready
        nop
        nop
        nop
        addi sp, sp, 32         # fp ready
        nop
        nop
        jr   ra                 # ra valid
        nop
        nop

end:
        wfi