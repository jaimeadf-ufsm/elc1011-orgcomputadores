.include "constants.asm"

# Estrutura "Campo"
# 8 bytes 
#
# Offset 0  <- mascara (word)
# Offset 4  <- deslocamento (word)

# Estrutura "Tipo de Instrução"
# 32 bytes
#
# Offset 0  <- Campo 0
# Offset 8  <- Campo 1
# Offset 16 <- Campo 2
# Offset 24 <- Campo 3

# Estrutura "Definição da Instrução"
# 20 bytes
#
# Offset 0  <- tipo do campo 0
# Offset 4  <- tipo do campo 1
# Offset 8  <- tipo do campo 2
# Offset 12 <- tipo do campo 3
# Offset 16 <- endereço do formato


.text
# argumentos
# $a0 <- código da instrução
#
# saída
# $v0 <- endereço para o tipo da instrução
# $v1 <- endereço para a definição da instrução
.globl lookupinst
lookupinst:
    srl $t0, $a0, 26                            # i  ) $t0 <- campo OPCODE deslocando a instrução
    andi $t1, $a0, 0x0000003F                   # ii ) $t1 <- campo FUNC isolando por uma máscara

    srl $t2, $a0, 16                            # iii) $t2 <- campo RT deslocado para o início
    andi $t2, $t2, 0x0000002F                   #      $t2 <- campo RT isolado por uma máscara
    
    beq $t0, $zero, lookupinst_op_00            # se OPCODE = 0x00, vá para lookupinst_op_00
    beq $t0, 0x1c, lookupinst_op_1c             # se OPCODE = 0x1c, vá para lookupinst_op_1c
    beq $t0, 0x01, lookupinst_op_01             # se OPCODE = 0x01, vá para lookupinst_op_01

lookupinst_op_default:
    bne $t0, 0x02, lookupinst_if_not_jump       # se OPCODE != 0x02, define o tipo da instrução para I
    bne $t0, 0x03, lookupinst_if_not_jump       # se OPCODE != 0x03, define o tipo da instrução para I

lookupinst_if_jump:
    la $v0, inst_type_j                          # $v0 <- endereço do tipo J
    j lookupinst_end_if_jump                     # vá para fora do bloco if

lookupinst_if_not_jump:
    la $v0, inst_type_i                          # $v0 <- endereço do tipo I

lookupinst_end_if_jump:
    la $t3, root_insts                           # $t3 <- endereço base da tabela raíz
    sll $t4, $t0, 2                              # $t4 <- deslocamento na tabela utlizando campo OPCODE
    add $t4, $t4, $t3                            # $t4 <- endereço efetivo na tabela raíz
    
    lw $v1, 0($t4)                               # $v1 <- endereço da definição da instrução

    jr $ra                                       # retorna ao chamador

lookupinst_op_00:
    la $v0, inst_type_r                          # $v0 <- endereço do tipo R

    la $t3, special_00_insts                     # $t3 <- endereço base da tabela especial 0x00
    sll $t4, $t1, 2                              # $t4 <- deslocamento na tabela utilizando o campo FUNC
    addu $t4, $t4, $t3                           # $t4 <- endereço efetivo na tabela especial 0x00
    
    lw $v1, 0($t4)                               # $v1 <- endereço da definição da instrução

    jr $ra                                       # retorna ao chamador

lookupinst_op_1c:
    la $v0, inst_type_r                          # $v0 <- endereço do tipo R

    la $t3, special_1c_insts                     # $t3 <- endereço base da tabela especial 0x1c
    sll $t4, $t1, 2                              # $t4 <- deslocamento na tabela utilizando campo FUNC
    addu $t4, $t4, $t3                           # $t4 <- endereço efetivo na tabela especial 0x1c
    
    lw $v1, 0($t4)                               # $v1 <- endereço da definição da instrução

    jr $ra                                       # retorna ao chamador

lookupinst_op_01:
    la $v0, inst_type_i                          # $v0 <- endereço do tipo I

    la $t3, special_rt_insts                     # $t3 <- endereço base da tabela especial RT
    sll $t4, $t2, 2                              # $t4 <- deslocamento na tabela utilizando o campo RT
    addu $t4, $t4, $t3                           # $t4 <- endereço efetivo na tabela especial RT
    
    lw $v1, 0($t4)                               # $v1 <- endereço da definição da instrução

    jr $ra                                       # retorna ao chamador
    

.data
# Tipo de Instrução R
#
#   OP    RS     RT    RD  SHAMT FUNCT
# -------------------------------------
# |  6  |  5  |  5  |  5  |  5  |  6  |
# -------------------------------------
# 000000 00000 00000 00000 00000 000000
inst_type_r:
# Campo RS:
.word 0x3E000000 # mascara      = 000000 11111 00000 00000 00000 000000
.word 21         # deslocamento = 21
# Campo RT:
.word 0x001F0000 # mascara      = 000000 00000 11111 00000 00000 000000
.word 16         # deslocamento = 16
# Campo RD:
.word 0x0000F800 # mascara      = 000000 00000 00000 11111 00000 000000
.word 11         # deslocamento = 11
# Campo SHAMT:
.word 0x000007C0 # mascara      = 000000 00000 00000 00000 11111 000000
.word 6          # deslocamento = 6


# Tipo de Instrução I
#
#   OP    RS     RT         IMM
# -------------------------------------
# |  6  |  5  |  5  |       16        |
# -------------------------------------
# 000000 00000 00000   0000000000000000
inst_type_i:
# Campo RS:
.word 0x03E00000 # mascara      = 000000 11111 00000   0000000000000000
.word 21         # deslocamento = 21
# Campo RT:
.word 0x001F0000 # mascara      = 000000 00000 11111   0000000000000000
.word 16         # deslocamento = 16
# Campo Imm:
.word 0x0000FFFF # mascara      = 000000 00000 00000   1111111111111111
.word 0          # deslocamento = 0
# Campo Ignorado:
.word 0          # mascara      = 000000 00000 00000 00000 00000 000000
.word 0          # deslocamento = 0


# Tipo de Instrução J
#
#   OP             ADDRESS
# -------------------------------------
# |  6  |             26              |
# -------------------------------------
# 000000     00000000000000000000000000
inst_type_j:
# Campo ADDRESS:
.word 0x3FFFFFFF # mascara      = 000000    11111111111111111111111111
.word 0          # deslocamento = 0
# Campo Ignorado:
.word 0          # mascara      = 000000    00000000000000000000000000
.word 0          # deslocamento = 0
# Campo Ignorado:
.word 0          # mascara      = 000000    00000000000000000000000000
.word 0          # deslocamento = 0
# Campo Ignorado:
.word 0          # mascara      = 0000000   00000000000000000000000000
.word 0          # deslocamento = 0


# Tabela raíz de Definições de Instrução
root_insts:
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word inst_def_addiu
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0

# Tabela especial definição de instruções com opcode 0x00
special_00_insts:
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word inst_def_addu
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0

# Tabela especial definição de instruções com opcode 0x1c
special_1c_insts:
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0

# Tabela especial definição de instruções com opcode 0x01
special_rt_insts:
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    
inst_def_addiu:
    .word OP_REG, OP_REG, OP_IMM_SIG, OP_NONE
    .word inst_fmt_addiu
    
inst_def_addu:
    .word OP_REG, OP_REG, OP_REG, OP_NONE
    .word inst_fmt_addu

# lw rt, offset(base)
inst_def_lw:
    .word OP_REG, OP_REG, OP_IMM_SIG, OP_NONE # = tipos dos campos 0 a 3
    .word inst_fmt_lw                         # = endereço do formato         

inst_fmt_addiu: .asciiz "addiu #1, #0, #2"
inst_fmt_addu: .asciiz "addu #2, #0, #1"
inst_fmt_lw:   .asciiz "lw #1, #2(#0)"


