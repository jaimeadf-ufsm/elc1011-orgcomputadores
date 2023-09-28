# Estrutura "Operando"
# 8 bytes
#
# Offset 0  <- tipo
# Offset 4  <- valor

# Estrutura "Instrução Decodificada"
# 32 bytes
#
# Offset 0  <- endereço
# Offset 4  <- código da instrução
# Offset 8  <- endereço para a definição da instrução
# Offset 12 <- Operando 0 
# Offset 20 <- Operando 1 
# Offset 28 <- Operando 3
# Offset 36 <- Operando 4 

# argumentos:
# $a0 <- endereço para a instrução decodificada
# $a1 <- endereço (valor) da instrução
# $a2 <- código da instrução
#
# pilha:
# $sp + 4  <- endereço para a instrução decodificada
# $sp + 0  <- $ra
.globl decodeinst
decodeinst:
    addiu $sp, $sp, -8                           # ajusta a pilha
    sw $a0, 4($sp)                               # armazena na pilha o argumento com o endereço da instrução decodificada
    sw $ra, 0($sp)                               # armazena na pilha o endereço de retorno

    sw $a1, 0($a0)                               # armazena o endereço (valor) na instrução decodificada 
    sw $a2, 4($a0)                               # armazena o código da instrução na instrução decodificada

    move $a0, $a2                                # $a0 <- código da instrução
    jal lookupinst                              # encontra a definição da instrução e o tipo

    lw $t0, 4($sp)                               # $t0 <- endereço da instrução decodificada
    sw $v1, 8($t0)                               # armazena o endereço da definição na instrução decodificada

    beq $v1, $zero, decodeinst_return            # retorna caso uma definição conhecida não foi encontrada

    move $a0, $t0                                # $a0 <- endereço para a instrução decodificada
    move $a1, $v0                                # $a1 <- endereço para os campos da instrução
    jal extractops                               # extrai os operandos

decodeinst_return:
    lw $ra, 0($sp)                               # restaura o endereço de retorno
    addiu $sp, $sp, 8                            # restaura a pilha
    jr $ra                                       # retorna ao chamador


# argumentos:
# $a0 <- endereço para a instrução decodificada
# $a1 <- endereço para o tipo da instrução (vetor de campos)
#
# pilha:
# $sp + 24 <- $s5
# $sp + 20 <- $s4
# $sp + 16 <- $s3
# $sp + 12 <- $s2
# $sp + 8  <- $s1
# $sp + 4  <- $s0
# $sp + 0  <- $ra
extractops:
    addiu $sp, $sp, -28                          # ajusta a pilha
    sw $s5, 24($sp)                              # armazena na pilha o registrador $s5
    sw $s4, 20($sp)                              # armazena na pilha o registrador $s4
    sw $s3, 16($sp)                              # armazena na pilha o registrador $s3
    sw $s2, 12($sp)                              # armazena na pilha o registrador $s2
    sw $s1, 8($sp)                               # armazena na pilha o registrador $s1
    sw $s0, 4($sp)                               # armazena na pilha o registrador $s0
    sw $ra, 0($sp)                               # armazena na pilha o endereço de retorno

    move $s0, $a0                                # $s0 <- argumento com o endereço da instrução decodificada
    move $s1, $a1                                # $s1 <- argumento com o endereço para o tipo da instruçÃo

    lw $s2, 0($s0)                               # $s2 <- carrega o endereço (valor) do código da instrução
    lw $s3, 4($s0)                               # $s3 <- carrega o código da instrução
    lw $s4, 8($s0)                               # $s4 <- carrega o endereço para a definição da instrução 

    move $s5, $zero                              # $s4 <- número do campo a ser decodificado
    
    j extractops_for_condition                   # verifica se existes campos

extractops_for_loop:
    sll $t0, $s5, 3                              # $t0 <- deslocamento no vetor com os campos
    addu $t0, $t0, $s1                           # $t0 <- endereço efetivo do campo

    move $a0, $s3                                # $a0 <- código da instrução

    lw $t1, 0($t0)                               # $t1 <- máscara do campo
    and $a0, $a0, $t1                            # aplica a máscara e isola o campo

    lw $t1, 4($t0)                               # $t1 <- deslocamento do campo
    srlv $a0, $a0, $t1                           # desloca o campo para o início

    sll $t0, $s5, 2                              # $t0 <- deslocamento no vetor com os tipos dos operandos
    addu $t0, $t0, $s4                           # $t1 <- endereço efetivo do tipo do operador em relação à definição

    lw $a1, 0($t0)                               # $a1 <- tipo do operador

    move $a2, $s2                                # $a1 <- endereço (valor) do código da instrução

    jal parseop                                  # decodifica o operador

    sll $t0, $s5, 3                              # $t0 <- deslocamento no vetor com os operandos
    addiu $t0, $t0, 12                           # $t0 <- deslocamento do operando na instrução decodificada
    addu $t0, $t0, $s0                           # $t0 <- endereço efetivo do operando

    sw $v0, 0($t0)                               # armazena o tipo do operando
    sw $v1, 4($t0)                               # armazena o valor do operando

extractops_for_increment:
    addiu $s5, $s5, 1

extractops_for_condition:
    blt $s5, 4, extractops_for_loop                  # se $s1 for menor que 4, continua o loop

    lw $s5, 24($sp)                              # restaura o registrador $s5
    lw $s4, 20($sp)                              # restaura o registrador $s4
    lw $s3, 16($sp)                              # restaura o registrador $s3
    lw $s2, 12($sp)                              # restaura o registrador $s2
    lw $s1, 8($sp)                               # restaura o registrador $s1
    lw $s0, 4($sp)                               # restaura o registrador $s0
    lw $ra, 0($sp)                               # restaura o endereço de retorno
    addiu $sp, $sp, 28                           # restaura a pilha

    jr $ra                                       # retorna ao chamador
    

# argumentos:
# $a0 <- valor
# $a1 <- tipo
# $a2 <- endereço (valor) do código da instrução
#
# saída:
# $v0 <- tipo do operando
# $v1 <- valor do operando
parseop:
    move $v1, $a0
    move $v0, $a1
    
    jr $ra
