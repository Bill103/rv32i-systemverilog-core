addi x1, x0, 5      // (x1 = 5)
addi x2, x1, 10     // (x2 = 15, EX hazard)
sw x2, 0(x0)        // (mem[0] = 15, forward required)
lw x3, 0(x0)        // (x3 = 15)
addi x4, x3, 1      // (x4 = 16, load-use hazard)
beq x1, x1, 8       // (Target = 0x14 + 8 = 0x1C)
addi x5, x0, 99     // squashed
addi x6, x0, 42     // (x6 = 42, branch target)