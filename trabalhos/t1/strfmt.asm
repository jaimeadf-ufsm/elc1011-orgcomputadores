.include "constants.asm"


.text

# Cria uma string com os operandos a partir de uma string de formato
#
# argumentos:
# $a0 : <endereço> para a string de destino
# $a1 : <endereço> para a string de formato
# $a2 : <endereço> para o vetor de <Operando>
#
# retorno:
# $v0 = <endereço> para o término da string de resultado
#
# pilha:
# $sp +  16 : $s3
# $sp +  12 : $s2
# $sp +  8  : $s1
# $sp +  4  : $s0
# $sp +  0  : $ra
.globl strfmt
strfmt:
    addiu $sp, $sp, -20                                    # ajusta a pilha
    sw $s3, 16($sp)                                        # armazena na pilha o registrador $s3
    sw $s2, 12($sp)                                        # armazena na pilha o registrador $s2
    sw $s1, 8($sp)                                         # armazena na pilha o registrador $s1
    sw $s0, 4($sp)                                         # armazena na pilha o registrador $s0
    sw $ra, 0($sp)                                         # armazena na pilha o endereço de retorno

    move $s0, $a0                                          # $s0 = <endereço> para a string de destino
    move $s1, $a1                                          # $s1 = <endereço> para a string de formato
    move $s2, $a2                                          # $s2 = <endereço> para o vetor de <Operando>
    
    move $s3, $zero                                        # $s3 = flag para prefixo de hashtag

    j strfmt_for_condition                                 # vá para a condição do for

strfmt_for_loop:
    beq $s3, $zero, strfmt_end_if_specifier                # se for prefixado de hashtag, formata o operador

strfmt_if_specifier:
    move $s3, $zero                                        # anula a flag de hashtag

    move $a0, $s0                                          # $a0 = <endereço> para o caractere atual da string de destino

    subu $a1, $t0, '0'                                     # $a1 = caractere dígito convertido em número
    sll $a1, $a1, 3                                        # $a1 = deslocamento no vetor de <Operando>
    addu $a1, $a1, $s2                                     # $a1 = endereço efetivo no vetor de <Operando>
    jal writeop                                            # escreve o operando

    move $s0, $v0                                          # $s1 = término da string de destino

    j strfmt_for_increment                                 # salta para o incremento

strfmt_end_if_specifier:
    bne $t0, '#', strfmt_end_if_hashtag                    # verifica se o caractere atual é uma hashtag

strfmt_if_hashtag:
    li $s3, 1                                              # habilita a flag de hashtag
    j strfmt_for_increment                                 # salta para o incremento

strfmt_end_if_hashtag:
    sb $t0, 0($s0)                                         # copia o caractere do formato para a string de destino
    addiu $s0, $s0, 1                                      # avança para o próximo caractere na string de destino

strfmt_for_increment:
    addiu $s1, $s1, 1                                      # avança para o próximo caractere na string de formato

strfmt_for_condition:
    lb $t0, 0($s1)                                         # carrega o caractere atual na string de formato
    bne $t0, $zero, strfmt_for_loop                        # se não estiver no término da string de formato, continua o loop

    sb $zero, 0($s0)                                       # insere o caractere de término na string de destino
    move $v0, $s0                                          # $v0 = término da string de destino

    lw $s3, 16($sp)                                        # restaura o registrador $s3
    lw $s2, 12($sp)                                        # restaura o registrador $s2
    lw $s1, 8($sp)                                         # restaura o registrador $s1
    lw $s0, 4($sp)                                         # restaura o registrador $s0
    lw $ra, 0($sp)                                         # restaura o endereço de retorno
    addiu $sp, $sp, 20                                     # restaura a pilha

    jr $ra                                                 # retorna ao chamador



writeop:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)

    lw $t0, 0($a1)
    lw $a1, 4($a1)

    beq $t0, OP_REG, writeop_case_reg
    beq $t0, OP_MEM_OFFSET, writeop_case_mem_offset
    beq $t0, OP_MEM_ADDR, writeop_case_mem_addr
    beq $t0, OP_IMM_SIG, writeop_case_imm_sig
    beq $t0, OP_IMM_UNSIG, writeop_case_imm_unsig

writeop_case_default:
        move $v0, $a0
        j writeop_epilogue

writeop_case_reg:
        jal regtostr
        j writeop_epilogue
    
writeop_case_mem_offset:
writeop_case_mem_addr:
        jal itostrhex
        j writeop_epilogue
    
writeop_case_imm_sig:
        jal itostrdec
        j writeop_epilogue

writeop_case_imm_unsig:
        jal utostrdec
        j writeop_epilogue
    
writeop_epilogue:
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra
