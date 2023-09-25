.include "constants.asm"

.text

.globl main
main:
	addiu $sp, $sp, -64

	move $a0, $sp
	la $a1, format
	la $a2, operands
	jal strfmt

	li $v0, 4
	move $a0, $sp
	syscall
	
	li $v0, 10
	syscall
		
.data
format:
.asciiz "[#3, #4](#0), #1, #2\n"

operands:
.word OP_REG, 31
.word OP_MEM_OFFSET, 0x100
.word OP_MEM_ADDR, 0x200
.word OP_IMM_SIG, 1
.word OP_IMM_UNSIG, 2
