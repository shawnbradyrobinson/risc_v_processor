.data
fibs:.word   0 : 19
size: .word  19

.text
      lasw   s0, fibs
      lasw   s5, size
      lw   s5, 0(s5)
      nop
      nop                # lw → use hazard (s5 used below)
      nop
      nop
      nop
      li   s2, 1
      nop
      nop
      nop
      sw   s2, 0(s0)
      nop
      nop
      nop
      sw   s2, 4(s0)
      nop
      nop
      nop
      addi s1, s5, -2
      nop                # s1 used in branch later
      nop
      nop
      nop
loop: lw   s3, 0(s0)
      nop
      nop
      nop
      lw   s4, 4(s0)
      nop
      nop                # lw → use hazards for s3, s4
      nop
      nop
      nop
      add  s2, s3, s4
      nop                # s2 used by sw
      nop
      nop
      nop
      sw   s2, 8(s0)
      nop
      nop
      nop
      addi s0, s0, 4
      nop
      nop
      nop
      addi s1, s1, -1
      nop                # s1 used by branch
      nop
      nop
      nop
      bne s1, zero, loop
      nop                # branch delay (conservative)
      nop
      nop
      nop
      lasw   a0, fibs
      add  a1, zero, s5
      nop                # a1 used by jal target
      nop
      nop
      nop
      jal  print
      nop                # return hazard safety
      nop
      nop
      nop
      j die
      nop
      nop
      nop

###############################################################
.data
space:.asciz  " "
head: .asciz  "The Fibonacci numbers are:\n"

.text
print:
      add  t0, zero, a0
      nop
      nop
      nop
      add  t1, zero, a1
      nop
      nop
      nop
      lasw   a0, head
      nop
      nop
      nop
      ori  a7, zero , 4
      nop                # a0/a7 before ecall
      nop
      nop
      nop
      ecall

out:
      lw   a0, 0(t0)
      nop
      nop                # lw → ecall use
      nop
      nop
      nop
      ori  a7, zero , 1
      nop
      nop
      nop
      nop
      ecall

      lasw   a0, space
      ori  a7, zero , 4
      nop
      nop
      nop
      ecall
      nop
      nop
      nop
      addi t0, t0, 4
      nop
      nop
      nop      
      addi t1, t1, -1
      nop                # t1 used in branch
      nop
      nop
      nop
      bne t1, zero , out
      nop
      nop
      nop
      nop
      jr   ra
      nop                # return safety
      nop
      nop
      nop
###############################################################

die:
      wfi
