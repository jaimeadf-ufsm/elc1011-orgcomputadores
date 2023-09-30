.include "constants.asm"

# struct <Operando>
# 8 bytes
#
# Offset 0  : <word> tipo
# Offset 4  : <word> valor

# struct <Instrução Decodificada>
# 32 bytes
#
# Offset 0  : <word> posição (endereço)
# Offset 4  : <word> código de máquina
# Offset 8  : <endereço> para <Definição da Instrução>
# Offset 12 : <Operando> 0 
# Offset 20 : <Operando> 1 
# Offset 28 : <Operando> 3
# Offset 36 : <Operando> 4 


# Decodifica a instrução em código de máquina.
#
# argumentos:
# $a0 : <endereço> para <Instrução Decodificada> em que será salvo o resultado
# $a1 : <word> posição (endereço)
# $a2 : <word> código de máquina
#
# pilha:
# $sp + 4  : <endereço> para <Instrução Decodificada>
# $sp + 0  : $ra
.globl decodeinst
decodeinst:
    addiu $sp, $sp, -8                           # ajusta a pilha
    sw $a0, 4($sp)                               # armazena o argumento com o <endereço> para a <Instrução Decodificada> na pilha
    sw $ra, 0($sp)                               # armazena o endereço de retorno na pilha

    sw $a1, 0($a0)                               # armazena a posição na instrução decodificada 
    sw $a2, 4($a0)                               # armazena o código de máquina na instrução decodificada

    move $a0, $a2                                # $a0 = código de máquina
    jal lookupinst                               # busca a definição e o tipo da instrução

    lw $t0, 4($sp)                               # $t0 = <endereço> da instrução decodificada
    sw $v1, 8($t0)                               # armazena o <endereço> para a <Definição da Instrução> na instrução decodificada

    beq $v1, $zero, decodeinst_return            # retorna caso uma definição válida não foi encontrado
                                                 # isto é, se o endereço for nulo

    move $a0, $t0                                # $a0 = <endereço> para a <Instrução Decodificada>
    move $a1, $v0                                # $a1 = <endereço> para o vetor de <Campo>
    jal extractops                               # extrai os operandos

decodeinst_return:
    lw $ra, 0($sp)                               # restaura o endereço de retorno
    addiu $sp, $sp, 8                            # restaura a pilha
    jr $ra                                       # retorna ao chamador


# Isola e decodifica os operandos de acordo com o tipo e com a definição da instrução.
#
# argumentos:
# $a0 : <endereço> para <Instrução Decodificada>
# $a1 : <endereço> para <Tipo da Instrução> (vetor de <Campo>)
#
# pilha:
# $sp + 24 : $s5
# $sp + 20 : $s4
# $sp + 16 : $s3
# $sp + 12 : $s2
# $sp + 8  : $s1
# $sp + 4  : $s0
# $sp + 0  : $ra
extractops:
    addiu $sp, $sp, -28                          # ajusta a pilha
    sw $s5, 24($sp)                              # armazena na pilha o registrador $s5
    sw $s4, 20($sp)                              # armazena na pilha o registrador $s4
    sw $s3, 16($sp)                              # armazena na pilha o registrador $s3
    sw $s2, 12($sp)                              # armazena na pilha o registrador $s2
    sw $s1, 8($sp)                               # armazena na pilha o registrador $s1
    sw $s0, 4($sp)                               # armazena na pilha o registrador $s0
    sw $ra, 0($sp)                               # armazena na pilha o endereço de retorno

    move $s0, $a0                                # $s0 = argumento com o <endereço> para <Instrução Decodificada>
    move $s1, $a1                                # $s1 = argumento com o <endereço> para o início do vetor de <Campo>

    lw $s2, 0($s0)                               # $s2 = carrega a posição da instrução decodificada
    lw $s3, 4($s0)                               # $s3 = carrega o código de máquina da instrução decodificada
    lw $s4, 8($s0)                               # $s4 = carrega o <endereço> para a <Definição da Instrução> da instrucão decodificada

    move $s5, $zero                              # $s5 = número do operando a ser decodificado
    
    j extractops_for_condition                   # verifica se existes campos

extractops_for_loop:
    sll $t0, $s5, 3                              # $t0 = deslocamento no vetor de <Campo>
    addu $t0, $t0, $s1                           # $t0 = endereço efetivo do <Campo> sendo isolado

    move $a0, $s3                                # $a0 = código de máquina

    lw $t1, 0($t0)                               # $t1 = máscara
    and $a0, $a0, $t1                            # $a0 = campo isolado pelo código de máscara

    lw $t1, 4($t0)                               # $t1 = deslocamento
    srlv $a0, $a0, $t1                           # $a0 = campo deslocado para o início

    sll $t0, $s5, 2                              # $t0 = deslocamento no vetor com os tipos de operandos
    addu $t0, $t0, $s4                           # $t1 = endereço efetivo do tipo do operando em relação a <Definição da Instrução>

    lw $a1, 0($t0)                               # $a1 = tipo do operando
    move $a2, $s2                                # $a2 = posição (endereço) da instrução
    jal parseop                                  # decodifica o operador

    sll $t0, $s5, 3                              # $t0 = deslocamento no vetor de <Operando>
    addiu $t0, $t0, 12                           # $t0 = deslocamento na <Instrução Decodificada>
    addu $t0, $t0, $s0                           # $t0 = endereço efetivo do operando

    sw $v0, 0($t0)                               # armazena o tipo do operando na instrução decodificada
    sw $v1, 4($t0)                               # armazena o valor do operando na instruação decodificada

extractops_for_increment:
    addiu $s5, $s5, 1

extractops_for_condition:
    blt $s5, 4, extractops_for_loop              # se $s5 for menor que 4, continua o for

    lw $s5, 24($sp)                              # restaura o registrador $s5
    lw $s4, 20($sp)                              # restaura o registrador $s4
    lw $s3, 16($sp)                              # restaura o registrador $s3
    lw $s2, 12($sp)                              # restaura o registrador $s2
    lw $s1, 8($sp)                               # restaura o registrador $s1
    lw $s0, 4($sp)                               # restaura o registrador $s0
    lw $ra, 0($sp)                               # restaura o endereço de retorno
    addiu $sp, $sp, 28                           # restaura a pilha

    jr $ra                                       # retorna ao chamador
    
# Aplica operações para ajustar o valor do campo ao valor do operando em assembly.
#
# argumentos:
# $a0 : <word> valor do campo
# $a1 : <word> tipo do operando
# $a2 : <word> PC da instrução
#
# saída:
# $v0 : <word> tipo do operando (cópia de $a1)
# $v1 : <word> valor do operando decodificado
parseop:
    beq $a1, OP_REG, parseop_type_reg                     # se o tipo for registrador, utiliza o valor absoluto do campo
    beq $a1, OP_IMM_UNSIG, parseop_type_imm_unsigned      # se o tipo for imediato sem sinal, utiliza o valor absoluto do campo
    beq $a1, OP_IMM_SIG, parseop_type_imm_signed          # se o tipo for imediato com sinal, extende o sinal do campo
    beq $a1, OP_MEM_OFFSET, parseop_type_mem_offset       # se o tipo for um deslocamento de endereço, calcula o endereço efetivo baseado em PC
    beq $a1, OP_MEM_ADDR, parseop_type_mem_address        # se o tipo for um endereço efetivo, calcula o endereço efetivo baseado em PC

parseop_type_default:
    li $v0, OP_NONE                                       # $v0 = OP_NONE 
    move $v1, $zero                                       # $v1 = 0

    jr $ra                                                # retorna ao chamador

parseop_type_reg:
    li $v0, OP_REG                                        # $v0 = OP_REG
    move $v1, $a0                                         # $v1 = $a0 (copia o valor do campo)

    jr $ra                                                # retorna ao chamador

parseop_type_imm_unsigned:
    li $v0, OP_REG                                        # $v0 = OP_REG
    move $v1, $a0                                         # $v1 = $a0 (copia o valor do campo)

    jr $ra                                                # retorna ao chamador

parseop_type_imm_signed:
    jal signextend                                        # extende o sinal do valor do campo

    li $v0, OP_IMM_SIG                                    # $v0 = OP_IMM_SIG
    move $v1, $v0                                         # $v1 = valor do campo estendido de 16 para 32 bits

    jr $ra                                                # retorna ao chamador

parseop_type_mem_offset:   
    addiu $sp, $sp, -4                                    # ajustar pilha
    sw $a2, 0($sp)                                        # armazena o valor de $a2 na pilha

    jal signextend

    li $v0, OP_MEM_OFFSET                                 # $v0 = OP_MEM_OFFSET

    lw $a2, 0($sp)                                        # carrega $a2 da pilha
    sll $v1, $v0, 2                                       # $v1 << 2
    addiu $t0, $a2, 4                                     # $t0 = PC + 4
    addu $v1, $v1, $t0                                    # $v1 = $v1 + $t0

    addiu $sp, $sp, 4                                     # restaura pilha
    jr $ra                                                # retorna ao chamador

parseop_type_mem_address:
    sll $v1, $a0, 2                                        # $v2 = $a0 << 2 (concatenamos 2 zeros à direita do valor do campo)
    addiu $t0, $a2, 4                                      # $t0 = PC + 4
    andi $t0, $t0, 0xF0000000                              # $t0 = isola os 4 bits mais significativos de PC + 4
    or $v1, $v1, $t1                                       # $v1 = substituí os bits mais significativos pelos de PC + 4
    
    li $v0, OP_MEM_ADDR
    jr $ra                                                 # retorna ao chamador

