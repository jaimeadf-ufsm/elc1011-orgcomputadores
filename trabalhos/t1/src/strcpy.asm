.text
# Copia a string fonte na string de destino.
#
# argumentos:
# $a0 : <endereço> para a string de destino
# $a1 : <endereço> para a string de fonte
.globl strcpy
strcpy:
    j strcpy_for_condition                                 # verifica a condição do loop

strcpy_for_loop:
    sb $t0, 0($a0)                                         # guarda o caractere atual na string de destino

    addiu $a0, $a0, 1                                      # incrementa a string de destino para o próximo caractere
    addiu $a1, $a1, 1                                      # incrementa a string de fonte para o próximo caractere

strcpy_for_condition:
    lb $t0, 0($a1)                                         # $t0 = caractere atual da string de fonte                        
    bne $t0, $zero, strcpy_for_loop                        # se o caractere for diferente de nulo, continua o loop

    sb $zero, 0($a0)                                       # insere o caractere de término na string de destino

    move $v0, $a0                                          # $v0 = término da string de destino
    jr $ra                                                 # retorna ao chamador

