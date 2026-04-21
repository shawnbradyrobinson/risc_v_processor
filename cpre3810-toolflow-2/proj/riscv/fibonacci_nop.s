.data
fibs:.word   0 : 19
size: .word  19

.text
      la   s0, fibs
      la   s5, size
      lw   s5, 0(s5)
      nop
      nop                # lw → use hazard (s5 used below)

      li   s2, 1
      sw   s2, 0(s0)
      sw   s2, 4(s0)

      addi s1, s5, -2
      nop                # s1 used in branch later

loop: lw   s3, 0(s0)
      lw   s4, 4(s0)
      nop
      nop                # lw → use hazards for s3, s4

      add  s2, s3, s4
      nop                # s2 used by sw

      sw   s2, 8(s0)

      addi s0, s0, 4
      addi s1, s1, -1
      nop                # s1 used by branch

      bne s1, zero, loop
      nop                # branch delay (conservative)

      la   a0, fibs
      add  a1, zero, s5
      nop                # a1 used by jal target

      jal  print
      nop                # return hazard safety

      j die


###############################################################
.data
space:.asciz  " "
head: .asciz  "The Fibonacci numbers are:\n"

.text
print:
      add  t0, zero, a0
      add  t1, zero, a1

      la   a0, head
      ori  a7, zero , 4
      nop                # a0/a7 before ecall
      ecall

out:
      lw   a0, 0(t0)
      nop
      nop                # lw → ecall use

      ori  a7, zero , 1
      nop
      ecall

      la   a0, space
      ori  a7, zero , 4
      nop
      ecall

      addi t0, t0, 4
      addi t1, t1, -1
      nop                # t1 used in branch

      bne t1, zero , out
      nop

      jr   ra
      nop                # return safety

###############################################################

die:
      wfi
