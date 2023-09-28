.include "constants.asm"

.data
str_reg_0:  .asciiz "$zero"
str_reg_1:  .asciiz "$at"
str_reg_2:  .asciiz "$v0"
str_reg_3:  .asciiz "$v1"
str_reg_4:  .asciiz "$a0"
str_reg_5:  .asciiz "$a1"
str_reg_6:  .asciiz "$a2"
str_reg_7:  .asciiz "$a3"
str_reg_8:  .asciiz "$t0"
str_reg_9:  .asciiz "$t1"
str_reg_10: .asciiz "$t2"
str_reg_11: .asciiz "$t3"
str_reg_12: .asciiz "$t4"
str_reg_13: .asciiz "$t5"
str_reg_14: .asciiz "$t6"
str_reg_15: .asciiz "$t7"
str_reg_16: .asciiz "$s0"
str_reg_17: .asciiz "$s1"
str_reg_18: .asciiz "$s2"
str_reg_19: .asciiz "$s3"
str_reg_20: .asciiz "$s4"
str_reg_21: .asciiz "$s5"
str_reg_22: .asciiz "$s6"
str_reg_23: .asciiz "$s7"
str_reg_24: .asciiz "$t8"
str_reg_25: .asciiz "$t9"
str_reg_26: .asciiz "$k0"
str_reg_27: .asciiz "$k1"
str_reg_28: .asciiz "$gp"
str_reg_29: .asciiz "$sp"
str_reg_30: .asciiz "$fp"
str_reg_31: .asciiz "$ra"


reg_names:
.word str_reg_0
.word str_reg_1
.word str_reg_2
.word str_reg_3
.word str_reg_4
.word str_reg_5
.word str_reg_6
.word str_reg_7
.word str_reg_8
.word str_reg_9
.word str_reg_10
.word str_reg_11
.word str_reg_12
.word str_reg_13
.word str_reg_14
.word str_reg_15
.word str_reg_16
.word str_reg_17
.word str_reg_18
.word str_reg_19
.word str_reg_20
.word str_reg_21
.word str_reg_22
.word str_reg_23
.word str_reg_24
.word str_reg_25
.word str_reg_26
.word str_reg_27
.word str_reg_28
.word str_reg_29
.word str_reg_30
.word str_reg_31



.text
.globl regtostr
regtostr:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)

    sll $t0, $a1, 2

    la $t1, reg_names
    addu $t1, $t1, $t0

    lw $a1, 0($t1)
    jal strcpy

    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra
