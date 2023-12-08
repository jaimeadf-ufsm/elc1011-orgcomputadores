.data
x: .word 0x90357274
y: .word 0x12341234

str_quotient: .asciiz "x / y = "
str_remainder: .asciiz "x % y = "

.text
main:
    lw $a0, x                                               # $a0 = valor do dividendo
    lw $a1, y                                               # $a1 = valor do divisor
    jal divide                                              # realiza a divisão
    
    move $s0, $v0                                           # $s0 = quociente da divisão
    move $s1, $v1                                           # $s1 = resto da divisão

    la $a0, str_quotient                                    # $a0 = endereço para a mensagem de quociente
    jal printstr                                            # imprime a mensagem de quociente
    
    move $a0, $s0                                           # $a0 = quociente da divisão
    jal printint                                            # imprime o quociente da divisão
    jal println                                             # imprime uma nova linha
    
    la $a0, str_remainder                                   # $a0 = endereço para a mensagem de resto
    jal printstr                                            # imprime a mensagem de resto
    
    move $a0, $s1
    jal printint                                            # imprime o resto da divisão
    jal println                                             # imprime uma nova linha
    
    jal exit                                                # encerra o programa

# Divide dois números inteiros sem sinal.
# x / y
#
# argumentos
# $a0 : dividendo x
# $a1 : divisor y
#
# retorno
# $v0 : quociente da divisão
# $v1 : resto da divisão
#
# registradores
# $s0 : divisor
# $s1 : iteração
# $v0 : resto lower (esquerda)
# $v1 : resto upper (direita)
#
# RESTO (64 bits)
# ---------------------------------
# | $v1 (32 bits) | $v0 (32 bits) |
# ---------------------------------
#
# mapa da pilha:
# $sp + 0 : $ra
# $sp + 4 : $s0
divide:
    addiu $sp, $sp, -8                                      # ajusta a pilha
    sw $ra, 0($sp)                                          # armazena na pilha o registrador $ra
    sw $s0, 4($sp)                                          # armazena na pilha o registrador $s0
    
    move $v0, $a0                                           # inicializa o resto lower com o dividendo
    move $v1, $zero                                         # inicializa o resto upper com zero
    
    move $s0, $a1                                           # copia o divisor
    
    move $a0, $v0                                           # copia o resto lower
    move $a1, $v1                                           # copia o resto upper
    jal sll64                                               # desloca o resto 1 bit para a esquerda com LSB = 0

    move $s1, $zero                                         # inicializa a iteração como zero
    
    j divide_for_condition                                  # vá para a condição do laço
    
divide_for_loop:
    bltu $v1, $s0, divide_else_greather_than_divider        # pula o bloco de código quando !(resto - divisor >= 0)

divide_if_greather_than_divider:
    subu $v1, $v1, $s0                                      # resto = resto - divisor

    move $a0, $v0                                           # copia o resto lower
    move $a1, $v1                                           # copia o resto upper
    jal sll64                                               # desloca o resto 1 bit para a esquerda com LSB = 0

    ori $v0, $v0, 1                                         # LSB = 1

    j divide_end_if_greather_than_divider                   # encerra o bloco de código

divide_else_greather_than_divider:
    move $a0, $v0                                           # copia o resto lower
    move $a1, $v1                                           # copia o resto upper
    jal sll64                                               # desloca o resto 1 bit para a esquerda com LSB = 0

divide_end_if_greather_than_divider:

divide_for_increment:
    addiu $s1, $s1, 1                                       # incrementa a iteração
    
divide_for_condition:
    bltu $s1, 32, divide_for_loop                           # continua o laço por 32 iterações
    
    srl $v1, $v1, 1                                         # desloca o resto para a direita

    lw $ra, 0($sp)                                          # restaura o registrador $ra
    lw $s0, 4($sp)                                          # restaura  o registrador $s0
    addiu $sp, $sp, 8                                       # restaura a pilha

    jr $ra                                                  # retorna ao chamador

# Realiza um deslocamento de 1 bit para a esquerda em 2 registradores.
#
# REGISTRADOR (64 bits)
# ---------------------------------
# | $a1 (32 bits) | $a0 (32 bits) |
# ---------------------------------
#
# argumentos:
# $a0 : registrador lower 
# $a1 : registrador upper
#
# retorno:
# $v0 : registrador lower  
# $v1 : registrador upper
sll64:
    srl $t0, $a0, 31                                        # extrai o MSB do registrador lower
    
    sll $v1, $a1, 1                                         # desloca o registrador upper 1 bit para a esquerda
    sll $v0, $a0, 1                                         # desloca o registrador lower 1 bit para a esquerda
    or $v1, $v1, $t0                                        # carrega o MSB anterior do registrador lower para o LSB do registrador upper
    
    jr $ra                                                  # retorna ao chamador

# Imprime uma string.
#
# argumentos:
# $a0 : endereço para o texto com terminador nulo
printstr:
    li $v0, 4                                               # serviço 4: imprime texto
    syscall                                                 # realiza uma chamada ao sistema
    
    jr $ra                                                  # retorna ao chamador
    
# Imprime um inteiro sem sinal.
#
# argumentos:
# $a0 : inteiro
printint:
    li $v0, 36                                              # serviço 36: imprime inteiro sem sinal
    syscall                                                 # realiza uma chamada ao sistema
    
    jr $ra                                                  # retorna ao chamador

println:
    li $v0, 11                                              # serviço 11: imprime caractere
    li $a0, '\n'                                            # $a0 = nova linha
    syscall                                                 # realiza uma chamada ao sistema

    jr $ra                                                  # retorna ao chamador

# Encerra o programa.
exit:
    li $v0, 10                                              # serviço 10: encerra o programa
    syscall                                                 # realiza uma chamada ao sistema
    
    jr $ra                                                  # retorna ao chamador
 
