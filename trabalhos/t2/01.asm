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
# $v0 : resto lower (esquerda)
# $v1 : resto upper (direita)
# $t0 : iteração
#
# RESTO (64 bits)
# ---------------------------------
# | $v1 (32 bits) | $v0 (32 bits) |
# ---------------------------------
divide:
    move $v0, $a0                                           # inicializa o resto lower com o dividendo
    move $v1, $zero                                         # inicializa o resto upper com zero
    
    move $t0, $zero                                         # inicializa a iteração como zero
    
    j divide_for_condition                                  # vá para a condição do laço
    
divide_for_loop:
    srl $t1, $v0, 31                                        # extrai o MSB do resto lower
    
    sll $v1, $v1, 1                                         # desloca o resto upper 1 bit para a esquerda
    sll $v0, $v0, 1                                         # desloca o resto lower 1 bit para a esquerda com o bit LSB = 0
    or $v1, $v1, $t1                                        # carrega o MSB do resto lower para o resto upper

    blt $v1, $a1, divide_end_if_greather_than_divider       # pula o bloco de código quando !(resto - divisor >= 0)

divide_if_greather_than_divider:
    subu $v1, $v1, $a1                                      # resto = resto - divisor
    ori $v0, $v0, 1                                         # LSB = 1
    
divide_end_if_greather_than_divider:

divide_for_increment:
    addiu $t0, $t0, 1                                       # incrementa a iteração
    
divide_for_condition:
    blt $t0, 32, divide_for_loop                            # continua o laço por 32 iterações
    
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
 
