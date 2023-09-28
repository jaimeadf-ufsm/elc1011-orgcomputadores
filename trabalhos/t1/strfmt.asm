.include "constants.asm"


.text
# $a0 = endereço para a string de resultado
# $a1 = endereço para a string de formato
# $a2 = endereço para os operandos
#
# $v0 = endereço para o fim do resultado
.globl strfmt
strfmt:
    addiu $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s3, 12($sp)
    sw $s2, 8($sp)
    sw $s1, 4($sp)
    sw $s0, 0($sp)

    move $s0, $a0
    move $s1, $a1
    move $s2, $a2

    j strfmt_write_condition  

strfmt_write_loop:
    beq $s3, '#', strfmt_if_specifier

strfmt_if_no_specifier:
    sb $s3, 0($s0)
    addiu $s0, $s0, 1

    j strfmt_end_if_specifier

strfmt_if_specifier:
    addiu $s1, $s1, 1

    lb $t0, 0($s1)
    subu $t0, $t0, '0'
    
    sll $t0, $t0, 3

    move $a0, $s0
    addu $a1, $s2, $t0

    jal writeop
    move $s0, $v0

strfmt_end_if_specifier:
    addiu $s1, $s1, 1

strfmt_write_condition:
    lb $s3, 0($s1)
    bne $s3, $zero, strfmt_write_loop

strfmt_epilogue:
    sb $zero, 0($s1)
    move $v0, $s1

    lw $ra, 16($sp)
    lw $s3, 12($sp)
    lw $s2, 8($sp)
    lw $s1, 4($sp)
    lw $s0, 0($sp)

    addiu $sp, $sp, 20

    jr $ra


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
    j writeop_case_default

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
    
writeop_case_default:
        move $v0, $a0
    
writeop_epilogue:
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra