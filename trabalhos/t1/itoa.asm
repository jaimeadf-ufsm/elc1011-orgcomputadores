# 0($sp) = $ra
#
# $a0 = endereço da string
# $a1 = inteiro com sinal
#
# $v0 = enderenço para o fim da string
#
# $t0 = caractere temporario
.globl itoadec
itoadec:
	addiu $sp, $sp, -4
	sw $ra, 0($sp)

	bgtz $a1, itoadec_convert

	li $t0, '-'
	sb $t0, 0($a0)

	addiu $a0, $a0, 1
	subu $a1, $zero, $a1

itoadec_convert:
	jal utoadec

	lw $ra, 0($sp)
	addiu $sp, $sp, 4

	jr $ra	

# $a0 = endereço da string
# $a1 = inteiro sem sinal
#
# $v0 = endereço para o fim da string
#
# $t0 = base (10)
# $t1 = endereço do carectere inicial do loop
# $t2 = endereço do carectere atual do loop
# $t3 = caractere temporário
# $t4 = caractere temporário
.globl utoadec
utoadec:
	li $t0, 10

	move $t1, $a0
	move $t2, $a0

utoadec_convert_loop:
	divu $a1, $t0 
	mflo $a1
	mfhi $t3

	addiu $t3, $t3, '0'
	sb $t3, 0($t2)

	addiu $t2, $t2, 1
	bne $a1, $zero, utoadec_convert_loop


	move $v0, $t2
	addiu $t2, $t2, -1
	
	j utoadec_reverse_condition

utoadec_reverse_loop:
	lb $t3, 0($t1)
	lb $t4, 0($t2)

	sb $t3, 0($t2)
	sb $t4, 0($t1)

	addiu $t1, $t1, 1
	addiu $t2, $t2, -1

utoadec_reverse_condition:
	blt $t1, $t2, utoadec_reverse_loop

	sb $zero, 0($v0)

	jr $ra

# $t0 = base (16)
# $t1 = endereco final do loop
# $t2 = endereco atual do loop
# $t3 = carectere temporário
# $v0 = endereço final do buffer 
.globl utoahex
utoahex:
	li $t0, 16

	addiu $v0, $a0, 10
	
	li $t3, '0'
	sb $t3, 0($a0)
	
	li $t3, 'x'
	sb $t3, 1($a0)
	
	addiu $t1, $a0, 2
	addiu $t2, $a0, 10
		
itohex_loop:
	addiu $t2, $t2, -1

	divu $a1, $t0

	mflo $a1 # quociente do número
	mfhi $t3 # resto do número
	
	bgeu $t3, 10, itohex_alphabet_digit 
	addiu $t3, $t3, '0'
	
	j itohex_condition
itohex_alphabet_digit:
	addiu $t3, $t3, 55 # 'A' - 10
	
	
itohex_condition:
	sb $t3, 0($t2)
	bne $t2, $t1, itohex_loop
	
	sb $zero, 0($v0)
	
	jr $ra
