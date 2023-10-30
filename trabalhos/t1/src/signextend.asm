.text
# Extende o sinal de um número de 16 bits para 32 bits.
#
# argumentos
# $a0 : <word> número em 16 bits
#
# retorno
# $v0 : <word> o valor estendido em 32 bits
.globl signextend
signextend:
  addiu $sp, $sp, -4                                      # ajusta a pilha 

  sh $a0, 0($sp)                                          # armazena $v0 da pilha
  lh $v0, 0($sp)                                          # carrega $v0 da pilha com sinal

  addiu $sp, $sp, 4                                       # restaura a pilha
  jr $ra                                                  # retorna ao chamador
