# $a0 = string de destino
# $a1 = string de fonte
.globl strcpy
strcpy:
    j strcpy_condition

strcpy_loop:
    sb $t0, 0($a0)

    addiu $a0, $a0, 1
    addiu $a1, $a1, 1

strcpy_condition:
    lb $t0, 0($a1)
    bne $t0, $zero, strcpy_loop

    sb $zero, 0($a0)

    move $v0, $a0
    jr $ra

