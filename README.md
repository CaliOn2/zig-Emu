# zig-Emu
a learning project in which i build an emulator or a self made set of instructions using a 16x16bit cache and a 64kb storage  

Instructions are Made of 4 segments of 4 bytes with a length of 4 bits  
bits 0-4: operator  
bits 5-8: cache adress of results  
bits 9-12: cache adress of bits doing the operation  
bits 13-16: cache adress of bits getting operated on  

a program ends when an instruction is all 0 bits  
example operation:  
ad:2 ad:3 ad:1 op  
0010 0001 0000 0110  
here register 2 (0010) is multiplied (0110) by register 1 (0001) and the result is put into register 0 (0000)

Operators:
- 0000 -> or
- 0001 -> xor
- 0010 -> and
- 0011 -> nand
- 0100 -> add
- 0101 -> subtract
- 0110 -> multiply
- 0111 -> shift left (because shift operations only need 4 bits ad:3 is used to move instead of the register[ad:3] 
- 1000 -> shift right (see above)
- 1001 -> set cache value (ad:2 and ad:3 are read as one byte and are put into register[ad:1])
- 1010 -> load a byte from storage
- 1011 -> store a byte in storage
- 1100 -> get the process counter 
- 1101 -> compare (is also used as jump)
- 1110 -> Special for Output (work in progress may change later)
- 1111 -> Special for input (see above)

Originally this was meant to be as a sort of emulator shell hybrid for a smartwatch however this project has since evolved into an emulator which will have a shell program running in it 
