# Extende o sinal de um número de 16 bits para 32 bits.
#
# argumentos
# $a0 : <word> número em 16 bits
#
# retorno
# $v0 : <word> o valor estendido em 32 bits
.globl signextend
signextend:
  addiu $sp, $sp, -4                                      # Cria espaço para a pilha     

  sh $a0, 0($sp)                                          # Armazena $v0 na pilha
  lh $v0, 0($sp)                                          # Carrega $v0 da pilha

  addiu $sp, $sp, 4                                       # Libera espaço da pilha
  jr $ra                                                  # Volta pra função chamadora
