
.data
register_names:
    .ascii "$zero"
    .space 3
    .ascii "$at"
    .space 5
    .ascii "$v0"
    .space 5
    .ascii "$v1"
    .space 5
    .ascii "$a0"
    .space 5
    .ascii "$a1"
    .space 5
    .ascii "$a2"
    .space 5
    .ascii "$a3"
    .space 5
    .ascii "$t0"
    .space 5
    .ascii "$t1"
    .space 5
    .ascii "$t2"
    .space 5
    .ascii "$t3"
    .space 5
    .ascii "$t4"
    .space 5
    .ascii "$t5"
    .space 5
    .ascii "$t6"
    .space 5
    .ascii "$t7"
    .space 5
    .ascii "$s0"
    .space 5
    .ascii "$s1"
    .space 5
    .ascii "$s2"
    .space 5
    .ascii "$s3"
    .space 5
    .ascii "$s4"
    .space 5
    .ascii "$s5"
    .space 5
    .ascii "$s6"
    .space 5
    .ascii "$s7"
    .space 5
    .ascii "$t8"
    .space 5
    .ascii "$t9"
    .space 5
    .ascii "$k0"
    .space 5
    .ascii "$k1"
    .space 5
    .ascii "$gp"
    .space 5
    .ascii "$sp"
    .space 5
    .ascii "$fp"
    .space 5
    .ascii "$ra"
    .space 5

.text
.globl regtostr
regtostr:
    sll $a1, $a1, 3

    la $t0, register_names
    addu $t0, $t0, $a1

    move $v0, $a0

    j regtostr_copy_condition

regtostr_copy_loop:
    sb $t1, 0($v0)

    addiu $v0, $v0, 1
    addiu $t0, $t0, 1
regtostr_copy_condition:
    lb $t1, 0($t0)
    bne $t1, $zero, regtostr_copy_loop

    sb $zero, 0($v0)

    jr $ra
