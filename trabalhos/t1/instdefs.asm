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
    # OPCODE = 0x00
    .word 0
    # OPCODE = 0x01
    .word 0
    # OPCODE = 0x02
    .word inst_def_j
    # OPCODE = 0x03
    .word inst_def_jal
    # OPCODE = 0x04
    .word inst_def_beq
    # OPCODE = 0x05
    .word inst_def_bne
    # OPCODE = 0x06
    .word inst_def_blez
    # OPCODE = 0x07
    .word inst_def_bgtz
    # OPCODE = 0x08
    .word inst_def_addi
    # OPCODE = 0x09
    .word inst_def_addiu
    # OPCODE = 0x0a
    .word inst_def_slti
    # OPCODE = 0x0b
    .word inst_def_sltiu
    # OPCODE = 0x0c
    .word inst_def_andi
    # OPCODE = 0x0d
    .word inst_def_ori
    # OPCODE = 0x0e
    .word inst_def_xori
    # OPCODE = 0x0f
    .word inst_def_lui
    # OPCODE = 0x10
    .word 0
    # OPCODE = 0x11
    .word 0
    # OPCODE = 0x12
    .word 0
    # OPCODE = 0x13
    .word 0
    # OPCODE = 0x14
    .word inst_def_beql
    # OPCODE = 0x15
    .word inst_def_bnel
    # OPCODE = 0x16
    .word inst_def_blezl
    # OPCODE = 0x17
    .word inst_def_bgtzl
    # OPCODE = 0x18
    .word 0
    # OPCODE = 0x19
    .word 0
    # OPCODE = 0x1a
    .word 0
    # OPCODE = 0x1b
    .word 0
    # OPCODE = 0x1c
    .word 0
    # OPCODE = 0x1d
    .word 0
    # OPCODE = 0x1e
    .word 0
    # OPCODE = 0x1f
    .word 0
    # OPCODE = 0x20
    .word inst_def_lb
    # OPCODE = 0x21
    .word inst_def_lh
    # OPCODE = 0x22
    .word inst_def_lwl
    # OPCODE = 0x23
    .word inst_def_lw
    # OPCODE = 0x24
    .word inst_def_lbu
    # OPCODE = 0x25
    .word inst_def_lhu
    # OPCODE = 0x26
    .word inst_def_lwr
    # OPCODE = 0x27
    .word 0
    # OPCODE = 0x28
    .word inst_def_sb
    # OPCODE = 0x29
    .word inst_def_sh
    # OPCODE = 0x2a
    .word inst_def_swl
    # OPCODE = 0x2b
    .word inst_def_sw
    # OPCODE = 0x2c
    .word 0
    # OPCODE = 0x2d
    .word 0
    # OPCODE = 0x2e
    .word inst_def_swr
    # OPCODE = 0x2f
    .word 0
    # OPCODE = 0x30
    .word inst_def_ll
    # OPCODE = 0x31
    .word 0
    # OPCODE = 0x32
    .word 0
    # OPCODE = 0x33
    .word 0
    # OPCODE = 0x34
    .word 0
    # OPCODE = 0x35
    .word 0
    # OPCODE = 0x36
    .word 0
    # OPCODE = 0x37
    .word 0
    # OPCODE = 0x38
    .word 0
    # OPCODE = 0x39
    .word 0
    # OPCODE = 0x3a
    .word 0
    # OPCODE = 0x3b
    .word 0
    # OPCODE = 0x3c
    .word 0
    # OPCODE = 0x3d
    .word 0
    # OPCODE = 0x3e
    .word 0
    # OPCODE = 0x3f
    .word 0
    # OPCODE = 0x40
    .word 0

# Tabela especial de <Definição da Instrução> com o campo OPCODE = 0x00
# Acessada com o deslocamento pelo campo FUNCT
special_00_insts:
    # FUNCT = 0x00
    .word inst_def_sll
    # FUNCT = 0x01
    .word 0
    # FUNCT = 0x02
    .word inst_def_srl
    # FUNCT = 0x03
    .word inst_def_sra
    # FUNCT = 0x04
    .word inst_def_sllv
    # FUNCT = 0x05
    .word 0
    # FUNCT = 0x06
    .word inst_def_srlv
    # FUNCT = 0x07
    .word inst_def_srav
    # FUNCT = 0x08
    .word inst_def_jr
    # FUNCT = 0x09
    .word inst_def_jalr
    # FUNCT = 0x0a
    .word inst_def_movz
    # FUNCT = 0x0b
    .word inst_def_movn
    # FUNCT = 0x0c
    .word inst_def_syscall
    # FUNCT = 0x0d
    .word inst_def_break
    # FUNCT = 0x0e
    .word 0
    # FUNCT = 0x0f
    .word inst_def_sync
    # FUNCT = 0x10
    .word inst_def_mfhi
    # FUNCT = 0x11
    .word inst_def_mthi
    # FUNCT = 0x12
    .word inst_def_mflo
    # FUNCT = 0x13
    .word inst_def_mtlo
    # FUNCT = 0x14
    .word 0
    # FUNCT = 0x15
    .word 0
    # FUNCT = 0x16
    .word 0
    # FUNCT = 0x17
    .word 0
    # FUNCT = 0x18
    .word inst_def_mult
    # FUNCT = 0x19
    .word inst_def_multu
    # FUNCT = 0x1a
    .word inst_def_div
    # FUNCT = 0x1b
    .word inst_def_divu
    # FUNCT = 0x1c
    .word 0
    # FUNCT = 0x1d
    .word 0
    # FUNCT = 0x1e
    .word 0
    # FUNCT = 0x1f
    .word 0
    # FUNCT = 0x20
    .word inst_def_add
    # FUNCT = 0x21
    .word inst_def_addu
    # FUNCT = 0x22
    .word inst_def_sub
    # FUNCT = 0x23
    .word inst_def_subu
    # FUNCT = 0x24
    .word inst_def_and
    # FUNCT = 0x25
    .word inst_def_or
    # FUNCT = 0x26
    .word inst_def_xor
    # FUNCT = 0x27
    .word inst_def_nor
    # FUNCT = 0x28
    .word 0
    # FUNCT = 0x29
    .word 0
    # FUNCT = 0x2a
    .word inst_def_slt
    # FUNCT = 0x2b
    .word inst_def_sltu
    # FUNCT = 0x2c
    .word 0
    # FUNCT = 0x2d
    .word 0
    # FUNCT = 0x2e
    .word 0
    # FUNCT = 0x2f
    .word 0
    # FUNCT = 0x30
    .word inst_def_tge
    # FUNCT = 0x31
    .word inst_def_tgeu
    # FUNCT = 0x32
    .word inst_def_tlt
    # FUNCT = 0x33
    .word inst_def_tltu
    # FUNCT = 0x34
    .word inst_def_teq
    # FUNCT = 0x35
    .word 0
    # FUNCT = 0x36
    .word inst_def_tne
    # FUNCT = 0x37
    .word 0
    # FUNCT = 0x38
    .word 0
    # FUNCT = 0x39
    .word 0
    # FUNCT = 0x3a
    .word 0
    # FUNCT = 0x3b
    .word 0
    # FUNCT = 0x3c
    .word 0
    # FUNCT = 0x3d
    .word 0
    # FUNCT = 0x3e
    .word 0
    # FUNCT = 0x3f
    .word 0

# Tabela especial de <Definição da Instrução> com o campo OPCODE = 0x1C
# Acessada com o deslocamento pelo campo FUNCT
special_1c_insts:
    # FUNCT = 0x00
    .word inst_def_madd
    # FUNCT = 0x01
    .word inst_def_maddu
    # FUNCT = 0x02
    .word inst_def_mul
    # FUNCT = 0x03
    .word 0
    # FUNCT = 0x04
    .word inst_def_msub
    # FUNCT = 0x05
    .word inst_def_msubu
    # FUNCT = 0x06
    .word 0
    # FUNCT = 0x07
    .word 0
    # FUNCT = 0x08
    .word 0
    # FUNCT = 0x09
    .word 0
    # FUNCT = 0x0a
    .word 0
    # FUNCT = 0x0b
    .word 0
    # FUNCT = 0x0c
    .word 0
    # FUNCT = 0x0d
    .word 0
    # FUNCT = 0x0e
    .word 0
    # FUNCT = 0x0f
    .word 0
    # FUNCT = 0x10
    .word 0
    # FUNCT = 0x11
    .word 0
    # FUNCT = 0x12
    .word 0
    # FUNCT = 0x13
    .word 0
    # FUNCT = 0x14
    .word 0
    # FUNCT = 0x15
    .word 0
    # FUNCT = 0x16
    .word 0
    # FUNCT = 0x17
    .word 0
    # FUNCT = 0x18
    .word 0
    # FUNCT = 0x19
    .word 0
    # FUNCT = 0x1a
    .word 0
    # FUNCT = 0x1b
    .word 0
    # FUNCT = 0x1c
    .word 0
    # FUNCT = 0x1d
    .word 0
    # FUNCT = 0x1e
    .word 0
    # FUNCT = 0x1f
    .word 0
    # FUNCT = 0x20
    .word inst_def_clz
    # FUNCT = 0x21
    .word inst_def_clo
    # FUNCT = 0x22
    .word 0
    # FUNCT = 0x23
    .word 0
    # FUNCT = 0x24
    .word 0
    # FUNCT = 0x25
    .word 0
    # FUNCT = 0x26
    .word 0
    # FUNCT = 0x27
    .word 0
    # FUNCT = 0x28
    .word 0
    # FUNCT = 0x29
    .word 0
    # FUNCT = 0x2a
    .word 0
    # FUNCT = 0x2b
    .word 0
    # FUNCT = 0x2c
    .word 0
    # FUNCT = 0x2d
    .word 0
    # FUNCT = 0x2e
    .word 0
    # FUNCT = 0x2f
    .word 0
    # FUNCT = 0x30
    .word 0
    # FUNCT = 0x31
    .word 0
    # FUNCT = 0x32
    .word 0
    # FUNCT = 0x33
    .word 0
    # FUNCT = 0x34
    .word 0
    # FUNCT = 0x35
    .word 0
    # FUNCT = 0x36
    .word 0
    # FUNCT = 0x37
    .word 0
    # FUNCT = 0x38
    .word 0
    # FUNCT = 0x39
    .word 0
    # FUNCT = 0x3a
    .word 0
    # FUNCT = 0x3b
    .word 0
    # FUNCT = 0x3c
    .word 0
    # FUNCT = 0x3d
    .word 0
    # FUNCT = 0x3e
    .word 0
    # FUNCT = 0x3f
    .word 0


# Tabela especial de <Definição da Instrução> com o campo OPCODE = 0x01
# Acessada com o deslocamento pelo campo RT
special_rt_insts:
    # RT = 0x00
    .word inst_def_bltz
    # RT = 0x01
    .word inst_def_bgez
    # RT = 0x02
    .word inst_def_bltzl
    # RT = 0x03
    .word inst_def_bgezl
    # RT = 0x04
    .word 0
    # RT = 0x05
    .word 0
    # RT = 0x06
    .word 0
    # RT = 0x07
    .word 0
    # RT = 0x08
    .word inst_def_tgei
    # RT = 0x09
    .word inst_def_tgeiu
    # RT = 0x0a
    .word inst_def_tlti
    # RT = 0x0b
    .word inst_def_tltiu
    # RT = 0x0c
    .word inst_def_teqi
    # RT = 0x0d
    .word 0
    # RT = 0x0e
    .word inst_def_tnei
    # RT = 0x0f
    .word 0
    # RT = 0x10
    .word inst_def_bltzal
    # RT = 0x11
    .word inst_def_bgezal
    # RT = 0x12
    .word inst_def_bltzall
    # RT = 0x13
    .word inst_def_bgczall
    # RT = 0x14
    .word 0
    # RT = 0x15
    .word 0
    # RT = 0x16
    .word 0
    # RT = 0x17
    .word 0
    # RT = 0x18
    .word 0
    # RT = 0x19
    .word 0
    # RT = 0x1a
    .word 0
    # RT = 0x1b
    .word 0
    # RT = 0x1c
    .word 0
    # RT = 0x1d
    .word 0
    # RT = 0x1e
    .word 0
    # RT = 0x1f
    .word 0
    
# Tabela raíz
inst_def_j:       definst("j #0", OP_MEM_ADDR, OP_NONE, OP_NONE, OP_NONE)
inst_def_jal:     definst("jal #0", OP_MEM_ADDR, OP_NONE, OP_NONE, OP_NONE)
inst_def_beq:     definst("beq #0, #1, #2", OP_REG, OP_REG, OP_MEM_OFFSET, OP_NONE)
inst_def_bne:     definst("bne #0, #1, #2", OP_REG, OP_REG, OP_MEM_OFFSET, OP_NONE)
inst_def_blez:    definst("blez #0, #2", OP_REG, OP_NONE, OP_MEM_OFFSET, OP_NONE)
inst_def_bgtz:    definst("bgtz #0, #2", OP_REG, OP_NONE, OP_MEM_OFFSET, OP_NONE)
inst_def_addi:    definst("addi #1, #0, #2", OP_REG, OP_REG, OP_IMM_SIG, OP_NONE)
inst_def_addiu:   definst("addiu #1, #0, #2", OP_REG, OP_REG, OP_IMM_SIG, OP_NONE)
inst_def_slti:    definst("slti #0, #1, #2", OP_REG, OP_REG, OP_IMM_SIG, OP_NONE)
inst_def_sltiu:   definst("sltiu #0, #1, #2", OP_REG, OP_REG, OP_IMM_UNSIG, OP_NONE)
inst_def_andi:    definst("andi #0, #1, #2", OP_REG, OP_REG, OP_IMM_UNSIG, OP_NONE)
inst_def_ori:     definst("ori #0, #1, #2", OP_REG, OP_REG, OP_IMM_UNSIG, OP_NONE)
inst_def_xori:    definst("xori #0, #1, #2", OP_REG, OP_REG, OP_IMM_UNSIG, OP_NONE)
inst_def_lui:     definst("lui #1, #2", OP_NONE, OP_REG, OP_IMM_UNSIG, OP_NONE)
inst_def_beql:    definst("beql #0, #1, #2", OP_REG, OP_REG, OP_MEM_OFFSET, OP_NONE)
inst_def_bnel:    definst("bne #0, #1, #2", OP_REG, OP_REG, OP_MEM_OFFSET, OP_NONE)
inst_def_blezl:   definst("bgtz #0, #2", OP_REG, OP_NONE, OP_MEM_OFFSET, OP_NONE)
inst_def_bgtzl:   definst("bgtzl #0, #2", OP_REG, OP_NONE, OP_MEM_OFFSET, OP_NONE)
inst_def_lb:      definst("lb #1, #2(#0)", OP_REG, OP_REG, OP_IMM_SIG, OP_NONE)
inst_def_lh:      definst("lh #1, #2(#0)", OP_REG, OP_REG, OP_IMM_SIG, OP_NONE)
inst_def_lwl:     definst("lwl #1, #2(#0)", OP_REG, OP_REG, OP_IMM_SIG, OP_NONE)
inst_def_lw:      definst("lw #1, #2(#0)", OP_REG, OP_REG, OP_IMM_SIG, OP_NONE)
inst_def_lbu:     definst("lbu #1, #2(#0)", OP_REG, OP_REG, OP_IMM_SIG, OP_NONE)
inst_def_lhu:     definst("lhu #1, #2(#0)", OP_REG, OP_REG, OP_IMM_SIG, OP_NONE)
inst_def_lwr:     definst("lwr #1, #2(#0)", OP_REG, OP_REG, OP_IMM_SIG, OP_NONE)
inst_def_sb:      definst("sb #1, #2(#0)", OP_REG, OP_REG, OP_IMM_SIG, OP_NONE)
inst_def_sh:      definst("sh #1, #2(#0)", OP_REG, OP_REG, OP_IMM_SIG, OP_NONE)
inst_def_swl:     definst("swl #1, #2(#0)", OP_REG, OP_REG, OP_IMM_SIG, OP_NONE)
inst_def_sw:      definst("sw #1, #2(#0)", OP_REG, OP_REG, OP_IMM_SIG, OP_NONE)
inst_def_swr:     definst("swr #1, #2(#0)", OP_REG, OP_REG, OP_IMM_SIG, OP_NONE)
inst_def_ll:      definst("ll #1, #2(#0)", OP_REG, OP_REG, OP_IMM_SIG, OP_NONE)

# Tabela 0x0 
inst_def_sll:     definst("sll #1, #0, #2", OP_REG, OP_REG, OP_REG, OP_NONE)
inst_def_srl:     definst("srl #2, #1, #3", OP_NONE, OP_REG, OP_REG, OP_IMM_UNSIG)
inst_def_sra:     definst("sra #2, #1, #3", OP_NONE, OP_REG, OP_REG, OP_IMM_UNSIG)
inst_def_sllv:    definst("sllv #2, #1, #0", OP_NONE, OP_REG, OP_REG, OP_IMM_UNSIG) 
inst_def_srlv:    definst("srlv #2, #1, #0", OP_NONE, OP_REG, OP_REG, OP_IMM_UNSIG) 
inst_def_srav:    definst("srav #2, #1, #0", OP_REG, OP_REG, OP_REG, OP_NONE)
inst_def_jr:      definst("jr #0", OP_REG, OP_NONE, OP_NONE,OP_NONE)
inst_def_jalr:    definst("jalr #0, #1", OP_REG,  OP_REG, OP_NONE, OP_NONE)
inst_def_movz:    definst("movz #2, #0, #1" OP_REG, OP_REG, OP_REG, OP_NONE)
inst_def_movn:    definst("movn #2, #0, #1" OP_REG, OP_REG, OP_REG, OP_NONE)
inst_def_syscall: definst("syscall", OP_NONE, OP_NONE, OP_NONE, OP_NONE)
inst_def_break:   definst("break", OP_NONE, OP_NONE, OP_NONE, OP_NONE)
inst_def_sync:    definst("sync #3", OP_NONE, OP_NONE, OP_NONE, OP_IMM_UNSIG)
inst_def_mfhi:    definst("mfhi #2", OP_NONE, OP_NONE, OP_REG, OP_NONE)
inst_def_mthi:    definst("mthi #2", OP_NONE, OP_NONE, OP_REG, OP_NONE)
inst_def_mflo:    definst("mflo #2", OP_NONE, OP_NONE, OP_REG, OP_NONE)
inst_def_mtlo:    definst("mtlo #2", OP_NONE, OP_NONE, OP_REG, OP_NONE)
inst_def_mult:    definst("mult #0, #1", OP_REG, OP_REG, OP_NONE, OP_NONE)
inst_def_multu:   definst("multu #0, #1", OP_REG, OP_REG, OP_NONE, OP_NONE)
inst_def_div:     definst("div #0, #1", OP_REG, OP_REG, OP_NONE, OP_NONE)
inst_def_divu:    definst("divu #0, #1", OP_REG, OP_REG, OP_NONE, OP_NONE)
inst_def_add:     definst("add #2, #0, #1", OP_REG, OP_REG, OP_REG, OP_NONE)
inst_def_addu:    definst("addu #2, #0, #1", OP_REG, OP_REG, OP_REG, OP_NONE)
inst_def_sub:     definst("sub #2, #0, #1", OP_REG, OP_REG, OP_REG, OP_NONE)
inst_def_subu:    definst("subu #2, #0, #1", OP_REG, OP_REG, OP_REG, OP_NONE)
inst_def_and:     definst("and #2, #0, #1", OP_REG, OP_REG, OP_REG, OP_NONE)
inst_def_or:      definst("or #2, #0, #1", OP_REG, OP_REG, OP_REG, OP_NONE)
inst_def_xor:     definst("xor #2, #0, #1", OP_REG, OP_REG, OP_REG, OP_NONE)
inst_def_nor:     definst("nor #2, #0, #1", OP_REG, OP_REG, OP_REG, OP_NONE)
inst_def_slt:     definst("slt #2, #0, #1", OP_REG, OP_REG, OP_REG, OP_NONE)
inst_def_sltu:    definst("sltu #2, #0, #1", OP_REG, OP_REG, OP_REG, OP_NONE)
inst_def_tge:     definst("tge #0, #1", OP_REG, OP_REG, OP_NONE, OP_NONE)
inst_def_tgeu:    definst("tgeu #0, #1", OP_REG, OP_REG, OP_NONE, OP_NONE)
inst_def_tlt:     definst("tlt #0, #1", OP_REG, OP_REG, OP_NONE, OP_NONE)
inst_def_tltu:    definst("tltu #0, #1", OP_REG, OP_REG, OP_NONE, OP_NONE)
inst_def_teq:     definst("teq #0, #1", OP_REG, OP_REG, OP_NONE, OP_NONE)
inst_def_tne:     definst("tne #0, #1", OP_REG, OP_REG, OP_NONE, OP_NONE)



# Tabela 0x01
inst_def_bltz:    definst("bltz #0, #2", OP_REG, OP_NONE, OP_MEM_OFFSET, OP_NONE)
inst_def_bgez:    definst("bgez #0, #2", OP_REG, OP_REG, OP_MEM_OFFSET, OP_NONE)
inst_def_bltzl:   definst("bltzl #0, #2", OP_REG, OP_NONE, OP_MEM_OFFSET, OP_NONE)
inst_def_bgezl:   definst("bgezl #0, #2", OP_REG, OP_NONE, OP_MEM_OFFSET, OP_NONE)
inst_def_tgei:    definst("tgei #0, #2", OP_REG, OP_NONE, OP_IMM_SIG, OP_NONE) 
inst_def_tgeiu:   definst("tgeiu #0, #2", OP_REG, OP_NONE, OP_IMM_UNSIG, OP_NONE) 
inst_def_tlti:    definst("tlti #0, #2", OP_REG, OP_NONE, OP_IMM_SIG, OP_NONE) 
inst_def_tltiu:   definst("tltiu #0, #2", OP_REG, OP_NONE, OP_IMM_UNSIG, OP_NONE)   
inst_def_teqi:    definst("teqi #0, #2", OP_REG, OP_NONE, OP_IMM_SIG, OP_NONE)   
inst_def_tnei:    definst("tnei #0, #2", OP_REG, OP_NONE, OP_IMM_SIG, OP_NONE) 
inst_def_bltzal:  definst("bltzal #0, #2", OP_REG, OP_NONE, OP_MEM_OFFSET, OP_NONE)
inst_def_bgezal:  definst("bgezal #0, #2", OP_REG, OP_NONE, OP_MEM_OFFSET, OP_NONE)
inst_def_bltzall: definst("bltzall #0, #2", OP_REG, OP_NONE, OP_MEM_OFFSET, OP_NONE)
inst_def_bgczall: definst("bzczall #0, #2", OP_REG, OP_NONE, OP_MEM_OFFSET, OP_NONE)

# Tabela 0x1c
inst_def_madd:    definst("madd #0, #1", OP_REG, OP_REG, OP_NONE, OP_NONE)
inst_def_maddu:   definst("maddu #0, #1", OP_REG, OP_REG, OP_NONE, OP_NONE)
inst_def_mul:     definst("mul #2, #0, #1", OP_REG, OP_REG, OP_REG, OP_NONE)
inst_def_msub:    definst("msub #0, #1", OP_REG, OP_REG, OP_NONE, OP_NONE)
inst_def_msubu:   definst("msubu #0, #1", OP_REG, OP_REG, OP_NONE, OP_NONE)
inst_def_clo:     definst("clo #2, #0", OP_REG, OP_REG, OP_REG, OP_NONE)
inst_def_clz:     definst("clz #2, #0", OP_REG, OP_REG, OP_REG, OP_NONE)  
