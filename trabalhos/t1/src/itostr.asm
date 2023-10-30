.text
# Transforma um inteiro com sinal em uma string decimal.
#
# argumentos:
# $a0 : <endereço> para a string de destino
# $a1 : <word> valor do inteiro com sinal
#
# retorno:
# $v0 : <endereço> para o término da string de resultado
#
# pilha:
# $sp + 0 : $ra
.globl itostrdec
itostrdec:
	addiu $sp, $sp, -4                                     # ajusta a pilha
	sw $ra, 0($sp)                                         # armazena na pilha o registrador $ra

	bgez $a1, itostrdec_convert                            # se o número for positivo ou nulo, pula para a conversão

	li $t0, '-'                                            # $t0 = '-'
	sb $t0, 0($a0)                                         # escreve o sinal de menos no início da string

	addiu $a0, $a0, 1                                      # desloca o endereço da string para o próxima caractere
	subu $a1, $zero, $a1                                   # $a1 = -$a1

itostrdec_convert:
	jal utostrdec                                          # converte o número para string como inteiro sem sinal

	lw $ra, 0($sp)                                         # restaura o registrador $ra
	addiu $sp, $sp, 4                                      # restaura a pilha

	jr $ra	                                               # retorna ao chamador

# Transforma um inteiro sem sinal em uma string decimal.
#
# argumentos:
# $a0 : <endereço> para string de destino
# $a1 : <word> valor do inteiro sem sinal
#
# retorno:
# $v0 : <endereço> para o término da string de destino
.globl utostrdec
utostrdec:
	li $t0, 10                                             # $t0 = base = 10

	move $t1, $a0                                          # $t1 = <endereço> para string de destino
	move $t2, $a0                                          # $t1 = <endereço> para string de destino

utostrdec_convert_loop:
	divu $a1, $t0                                          # divide o inteiro pela base
	mflo $a1                                               # $a1 = quociente da divisão
	mfhi $t3                                               # $t3 = resto da divisão

	addiu $t3, $t3, '0'                                    # $t3 = dígito em representação ASCII
	sb $t3, 0($t2)                                         # armazena o dígito na string de destino

utostrdec_convert_condition:
	addiu $t2, $t2, 1                                      # incrementa $t2 para o próxima caractere
	bne $a1, $zero, utostrdec_convert_loop                 # se o inteiro for maior que zero, continua a itereração

	move $v0, $t2                                          # $v0 = <endereço> para o término da string de destino
	addiu $t2, $t2, -1                                     # $t2 = <endereço> para o último caractere da string de destino
	
	j utostrdec_reverse_for_condition                      # verifica a condição de reversão

utostrdec_reverse_for_loop:
	lb $t3, 0($t1)                                         # carrega o caractere da direita em $t1
	lb $t4, 0($t2)                                         # carrega o caractere da esquerda em $t4

	sb $t3, 0($t2)                                         # armazena o caractere da esquerda no <endereço> da direita
	sb $t4, 0($t1)                                         # armazena o caractere da direita no <endereço> da esquerda

	addiu $t1, $t1, 1                                      # desloca o endereço em $t1 para o caractere a direita
	addiu $t2, $t2, -1                                     # desloca o endereço em $t2 para o caractere a esquerda

utostrdec_reverse_for_condition:
	blt $t1, $t2, utostrdec_reverse_for_loop               # se o <endereço> para o caractere da esquerda for menor que o caractere da direita, continua a inversão

	sb $zero, 0($v0)                                       # insere o caractere de término na string de destino
	jr $ra                                                 # retorna ao chamador

# Transforma um inteiro em uma string hexadecimal preenchida com zeros.
# Exemplo: 0x00000010
#
# argumentos:
# $a0 : <endereço> para a string de destino
# $a1 : <word> valor do inteiro com sinal
#
# retorno:
# $v0 : <endereço> para o término da string de resultado
.globl itostrhex
itostrhex:
	li $t0, 16                                             # $t0 = base = 16

	addiu $v0, $a0, 10                                     # $v0 = término da string de destino
	
	li $t3, '0'                                            # $t3 = '0'
	sb $t3, 0($a0)                                         # armazena o caractere '0' na posição 0 do destino
	
	li $t3, 'x'                                            # $t3 = 'x'                 
	sb $t3, 1($a0)                                         # armazena o caractere '0' na posição 1 do destino
	
	addiu $t1, $a0, 2                                      # $t1 = <endereço> para o início dos dígitos
	addiu $t2, $a0, 10                                     # $t2 = <endereço> para o fim dos dígitos
		
itostrhex_loop:
	addiu $t2, $t2, -1                                     # $t2 = <endereço> para string de destino do dígito atual

	divu $a1, $t0                                          # divide o inteiro pela base
	mflo $a1                                               # $a1 = quociente da divisão
	mfhi $t3                                               # $t3 = resto da divisão
	
	bgeu $t3, 10, itostrhex_if_alphabet_digit              # se o dígito for maior que 10, converte com o alfabeto
	addiu $t3, $t3, '0'                                    # $t3 = dígito em representação ASCII númerica
	
	j itostrhex_condition                                  # verifica a condição da conversão

itostrhex_if_alphabet_digit:
	addiu $t3, $t3, 55                                     # $t3 = dígito em representação ASCII alfabética
	
itostrhex_condition:
	sb $t3, 0($t2)                                         # armazena o dígita na string de destino 
	bne $t2, $t1, itostrhex_loop                           # se não estiver no dígito final, continua o loop
	
	sb $zero, 0($v0)                                       # insere o caractere de término na string de destino
	jr $ra                                                 # retorna ao chamador
