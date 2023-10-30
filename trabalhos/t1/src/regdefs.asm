.text
# Transforma o número do registrador para sua string equivalente.
# 
# $a0 : <endereço> para a string de destino
# $a1 : <word> número do registrador
#
# retorno:
# $v0 = <endereço> para o término da string de resultado
.globl regtostr
regtostr:
    addiu $sp, $sp, -4                                     # ajusta a pilha
    sw $ra, 0($sp)                                         # armazena na pilha o endereço de retorno

    sll $t0, $a1, 2                                        # $t0 = deslocamento na tabela de nome

    la $t1, reg_names                                      # $t1 = <endereço> da tabela de nomes
    addu $t1, $t1, $t0                                     # $t1 = <endereço> efetivo na tabela de nomes

    lw $a1, 0($t1)                                         # $a1 = <endereço> para a string de nome
    jal strcpy                                             # copia o nome para a string de destino

    lw $ra, 0($sp)                                         # restaura o endereço de retorno
    addiu $sp, $sp, 4                                      # restaura a pilha
    jr $ra                                                 # retorna ao chamador


.data
# Tabela da string equivalente ao determinado número do registrador.
reg_names:
.word reg_name_0
.word reg_name_1
.word reg_name_2
.word reg_name_3
.word reg_name_4
.word reg_name_5
.word reg_name_6
.word reg_name_7
.word reg_name_8
.word reg_name_9
.word reg_name_10
.word reg_name_11
.word reg_name_12
.word reg_name_13
.word reg_name_14
.word reg_name_15
.word reg_name_16
.word reg_name_17
.word reg_name_18
.word reg_name_19
.word reg_name_20
.word reg_name_21
.word reg_name_22
.word reg_name_23
.word reg_name_24
.word reg_name_25
.word reg_name_26
.word reg_name_27
.word reg_name_28
.word reg_name_29
.word reg_name_30
.word reg_name_31

reg_name_0:  .asciiz "$zero"
reg_name_1:  .asciiz "$at"
reg_name_2:  .asciiz "$v0"
reg_name_3:  .asciiz "$v1"
reg_name_4:  .asciiz "$a0"
reg_name_5:  .asciiz "$a1"
reg_name_6:  .asciiz "$a2"
reg_name_7:  .asciiz "$a3"
reg_name_8:  .asciiz "$t0"
reg_name_9:  .asciiz "$t1"
reg_name_10: .asciiz "$t2"
reg_name_11: .asciiz "$t3"
reg_name_12: .asciiz "$t4"
reg_name_13: .asciiz "$t5"
reg_name_14: .asciiz "$t6"
reg_name_15: .asciiz "$t7"
reg_name_16: .asciiz "$s0"
reg_name_17: .asciiz "$s1"
reg_name_18: .asciiz "$s2"
reg_name_19: .asciiz "$s3"
reg_name_20: .asciiz "$s4"
reg_name_21: .asciiz "$s5"
reg_name_22: .asciiz "$s6"
reg_name_23: .asciiz "$s7"
reg_name_24: .asciiz "$t8"
reg_name_25: .asciiz "$t9"
reg_name_26: .asciiz "$k0"
reg_name_27: .asciiz "$k1"
reg_name_28: .asciiz "$gp"
reg_name_29: .asciiz "$sp"
reg_name_30: .asciiz "$fp"
reg_name_31: .asciiz "$ra"