addi x1, x0, 0      // x1 = Memory address pointer
addi x2, x0, 10     // x2 = Loop counter
addi x3, x0, 0      // x3 = Current fib number
addi x4, x0, 1      // x4 = Next fib number

sw x3, 0(x1)        // Store current fib number into memory
add x5, x3, x4      // Calculate the next number
add x3, x0, x4      // Current becomes next
add x4, x0, x5      // Next becomes the newly calculated number

addi x1, x1, 4      // Move memory pointer forward by 4 bytes
addi x2, x2, -1     // Decrement loop counter

beq x2, x0, 8       // If the counter hits 0, jump to end loop
jal x0, -28         // Otherwise jump back to loop start

jal x0, 0           // Infinite loop