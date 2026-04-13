.data
.text
    # 1. Initialize Stack Pointer (The "Long Way")
    lui sp, 0x80000        
    addi sp, sp, -4        # sp (x2) is now 0x7FFFFFFC
    
    # 2. MMIO Setup
    lui  x3, 0x10010       
    addi x3, x3, 0x0010    
    addi x4, x0, 60        
    sw   x4, 0(x3)         
    
    # 3. Clean Stack Operations
    # Use a different register for your "100" math to avoid confusing the SP
    addi x5, x0, 100       # Use x5 instead of modifying x2/sp directly
    
    addi sp, sp, -4        # Decrement stack pointer
    sw   ra, 0(sp)         # Save return address to memory
    
    wfi
