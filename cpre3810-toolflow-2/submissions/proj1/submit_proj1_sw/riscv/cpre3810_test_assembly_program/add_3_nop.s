    .data
    .text
    .globl main
main:
    # repeated doubling
    # checking wrap-around behavior

    addi x1, x0, 1        # x1=1

    # double x1 repeatedly to get 1 << 30
    add x1, x1, x1        # x1=2  (1<<1)
    nop
    nop
    nop
    nop
    nop
    add x1, x1, x1        # x1=4  (1<<2)
       nop
    nop
    nop
    nop
    nop
    add x1, x1, x1        # x1=8  (1<<3)
       nop
    nop
    nop
    nop
    nop
    add x1, x1, x1        # x1=16 (1<<4)
       nop
    nop
    nop
    nop
    nop
    add x1, x1, x1        # 5      etc.
       nop
    nop
    nop
    nop
    nop
    add x1, x1, x1        # 6      etc.
       nop
    nop
    nop
    nop
    nop
    add x1, x1, x1        # 7
       nop
    nop
    nop
    nop
    nop
    add x1, x1, x1        # 8
       nop
    nop
    nop
    nop
    nop
    add x1, x1, x1        # 9
       nop
    nop
    nop
    nop
    nop
    add x1, x1, x1   
       nop
    nop
    nop
    nop
    nop
    add x1, x1, x1  
       nop
    nop
    nop
    nop
    nop
    add x1, x1, x1     
       nop
    nop
    nop
    nop
    nop
    add x1, x1, x1  
       nop
    nop
    nop
    nop
    nop
    add x1, x1, x1 
       nop
    nop
    nop
    nop
    nop
    add x1, x1, x1 
       nop
    nop
    nop
    nop
    nop
    add x1, x1, x1 
       nop
    nop
    nop
    nop
    nop
    add x1, x1, x1     
       nop
    nop
    nop
    nop
    nop
    add x1, x1, x1 
       nop
    nop
    nop
    nop
    nop
    add x1, x1, x1 
       nop
    nop
    nop
    nop
    nop
    add x1, x1, x1 
       nop
    nop
    nop
    nop
    nop
    add x1, x1, x1 
       nop
    nop
    nop
    nop
    nop
    add x1, x1, x1
       nop
    nop
    nop
    nop
    nop
    add x1, x1, x1     
       nop
    nop
    nop
    nop
    nop
    add x1, x1, x1 
       nop
    nop
    nop
    nop
    nop
    add x1, x1, x1     
   nop
    nop
    nop
    nop
    nop
    add x1, x1, x1   
   nop
    nop
    nop
    nop
    nop
    add x1, x1, x1     
   nop
    nop
    nop
    nop
    nop
    add x1, x1, x1    
   nop
    nop
    nop
    nop
    nop
    add x1, x1, x1
   nop
    nop
    nop
    nop
    nop
    add x1, x1, x1        # 30 ---> x1=1<<30 
   nop
    nop
    nop
    nop
    nop

    # copy x1 to x2
    add x2, x1, x0        # x2=x1
    # add x1+x2 --> (1<<31)
       nop
    nop
    nop
    nop
    nop
    add x3, x1, x2
    # add x3+x3 ---> wrap around
       nop
    nop
    nop
    nop
    nop
    add x4, x3, x3
       nop
    nop
    nop
    nop
    nop
    add x5, x4, x0        # x5=0
       nop
    nop
    nop
    nop
    nop
    add x6, x3, x0        # make sure x6 is preserved
   nop
    nop
    nop
    nop
    nop
    addi a7, x0, 93
    wfi
