.include "constants.asm"

.text

.globl main
main:
	la $a0, dinst
	li $a1, 0x00400000
	li $a2, 0x00062021 #0x27BDFFF8
	jal decodeinst
	
	# 001001 11101 11101 1111111111111000
	# 0x09   0x1D  0x1D  0xFFF8

	la $t0, dinst_definition
	lw $t1, 0($t0)

	la $a0, dout
	lw $a1, 16($t1)
	la $a2, dinst_operands
	jal strfmt

	li $v0, 4
	la $a0, dout
	syscall
	
	li $v0, 10
	syscall

.data
dinst:
dinst_address:    .word 0
dinst_code:       .word 0
dinst_definition: .word 0
dinst_operands:
dinst_operand_0:  .word 0, 0
dinst_operand_1:  .word 0, 0
dinst_operand_2:  .word 0, 0
dinst_operand_3:  .word 0, 0

dout: .space 128
