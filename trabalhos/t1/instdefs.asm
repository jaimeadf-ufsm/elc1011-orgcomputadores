.include "constants.asm"

.macro definst (%fmt, %op0, %op1, %op2, %op3)
.data
.word %op0, %op1, %op2, %op3
.word definst_fmt

definst_fmt: .asciiz %fmt
.end_macro
# struct <Campo>
# 8 bytes 
#
# Offset 0  : <word> mascara
# Offset 4  : <word> deslocamento

# struct <Tipo da Instrução>
# 32 bytes
#
# Offset 0  : <Campo> 0
# Offset 8  : <Campo> 1
# Offset 16 : <Campo> 2
# Offset 24 : <Campo> 3

# struct <Definição da Instrução>
# 20 bytes
#
# Offset 0  : <word> tipo do operando 0
# Offset 4  : <word> tipo do operando 1
# Offset 8  : <word> tipo do operando 2
# Offset 12 : <word> tipo do operando 3
# Offset 16 : <endereço> string de formato


.text
# Encontra o tipo (I, R ou J) e a definição da instrução que o código se refere.
# 
# argumentos
# $a0 : <word> código de máquina
#
# retorno
# $v0 : <endereço> para <Tipo da Instrução>
# $v1 : <endereço> para <Definição da Instrução>
.globl lookupinst
lookupinst:
    srl $t0, $a0, 26                            # i  ) $t0 = campo OPCODE (>> 26)
    andi $t1, $a0, 0x0000003F                   # ii ) $t1 = campo FUNCT (000000 00000 00000 00000 00000 111111)

    srl $t2, $a0, 16                            # iii) $t2 = campo RT (deslocado para início)
    andi $t2, $t2, 0x0000002F                   #      $t2 = campo RT (isolado por uma máscara)
    
    beq $t0, $zero, lookupinst_op_00            # se campo OPCODE = 0x00, busca na tabela especial 0x00
    beq $t0, 0x1c, lookupinst_op_1c             # se campo OPCODE = 0x1c, busca na tabela especial 0x1c
    beq $t0, 0x01, lookupinst_op_01             # se campo OPCODE = 0x01, busca na tabela especial 0x01

lookupinst_op_default:
    beq $t0, 0x02, lookupinst_if_jump           # se campo OPCODE = 0x02 ou se campo OPCODE = 0x03,
    beq $t0, 0x03, lookupinst_if_jump           # define o tipo da instrução para J

lookupinst_if_not_jump:
    la $v0, inst_type_i                          # $v0 = endereço para do tipo I
    j lookupinst_end_if_jump                     # salta para fora do bloco if

lookupinst_if_jump:
    la $v0, inst_type_j                          # $v0 = endereço para do tipo J

lookupinst_end_if_jump:
    la $t3, root_insts                           # $t3 = endereço base da tabela raíz
    sll $t4, $t0, 2                              # $t4 = deslocamento na tabela utilizando o campo OPCODE
    add $t4, $t4, $t3                            # $t4 = endereço efetivo na tabela raíz
    
    lw $v1, 0($t4)                               # $v1 = endereço da definição da instrução

    jr $ra                                       # retorna ao chamador

lookupinst_op_00:
    la $v0, inst_type_r                          # $v0 = endereço do tipo R

    la $t3, special_00_insts                     # $t3 = endereço base da tabela especial 0x00
    sll $t4, $t1, 2                              # $t4 = deslocamento na tabela utilizando o campo FUNCT
    addu $t4, $t4, $t3                           # $t4 = endereço efetivo na tabela especial 0x00
    
    lw $v1, 0($t4)                               # $v1 = endereço da definição da instrução

    jr $ra                                       # retorna ao chamador

lookupinst_op_1c:
    la $v0, inst_type_r                          # $v0 = endereço para o tipo R

    la $t3, special_1c_insts                     # $t3 = endereço base da tabela especial 0x1c
    sll $t4, $t1, 2                              # $t4 = deslocamento na tabela utilizando o campo FUNCT
    addu $t4, $t4, $t3                           # $t4 = endereço efetivo na tabela especial 0x1c
    
    lw $v1, 0($t4)                               # $v1 = endereço da definição da instrução

    jr $ra                                       # retorna ao chamador

lookupinst_op_01:
    la $v0, inst_type_i                          # $v0 = endereço do tipo I

    la $t3, special_rt_insts                     # $t3 = endereço base da tabela especial RT
    sll $t4, $t2, 2                              # $t4 = deslocamento na tabela utilizando o campo RT
    addu $t4, $t4, $t3                           # $t4 = endereço efetivo na tabela especial RT
    
    lw $v1, 0($t4)                               # $v1 = endereço da definição da instrução

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
.word 0          # mascara      = 000000 00000 00000   0000000000000000
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
.word 0x03FFFFFF # mascara      = 000000    11111111111111111111111111
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


# Tabela raíz de <Definição da Instrução>
# Acessada com o deslocamento pelo campo OPCODE
root_insts:
    .word 0
    .word 0
    .word inst_def_j
    .word inst_def_jal
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
    .word inst_def_lw
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

# Tabela especial de <Definição da Instrução> com o campo OPCODE = 0x00
# Acessada com o deslocamento pelo campo FUNCT
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

# Tabela especial de <Definição da Instrução> com o campo OPCODE = 0x1C
# Acessada com o deslocamento pelo campo FUNCT
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

# Tabela especial de <Definição da Instrução> com o campo OPCODE = 0x01
# Acessada com o deslocamento pelo campo RT
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

inst_def_j:     definst("j #0", OP_MEM_ADDR, OP_NONE, OP_NONE, OP_NONE)
inst_def_jal:   definst("jal #0", OP_MEM_ADDR, OP_NONE, OP_NONE, OP_NONE)
inst_def_addiu: definst("addiu #1, #0, #2", OP_REG, OP_REG, OP_IMM_SIG, OP_NONE)
inst_def_addu:  definst("addu #2, #0, #1", OP_REG, OP_REG, OP_REG, OP_NONE)
inst_def_lw:    definst("lw #1, #2(#0)", OP_REG, OP_REG, OP_IMM_SIG, OP_NONE)

