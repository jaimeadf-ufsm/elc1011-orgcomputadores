#*******************************************************************************
# exercicio012.s               Copyright (C) 2017 Giovani Baratto
# This program is free software under GNU GPL V3 or later version
# see http://www.gnu.org/licences
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# versão: 0.2
# Descrição: programa para calcular o fatorial de um número: versão recursiva
# Documentação:
# Assembler: MARS
# Revisões:
# Rev #  Data           Nome   Comentários
# 0.1    ??/??/????     GBTO   versão inicial 
# 0.2    25/04/2018     GBTO   formatação e adição de comentários 
# 0.3    15/12/2021     GBTO   formatação, troca de pseudo instruções por
#                              instruções básicas e uso da diretiva eqv
#*******************************************************************************
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M     O                 #

.text                               # segmento de texto (código)
.globl main                         # main pode ser referenciado em outros arquivos

# definição dos valores numéricos com a diretiva .eqv
.eqv        SERVICO_IMPRIME_INTEIRO     1
.eqv        SERVICO_IMPRIME_STRING      4
.eqv        SERVICO_IMPRIME_CARACTERE   11
.eqv        SERVICO_TERMINA_PROGRAMA    17
.eqv        SUCESSO                     0

################################################################################
main:
#
# void main(void)
# {     
#     int k;
#     int fat;     
#     k = 5;     
#     fat = fatorial(k);     
#     printf("O fatorial de %d é %d\n",k, fat); 
#     return;
# }
#------------------------------------------------------------------------------    
#      mapa da pilha
#     ----------------
#     k     : $sp + 4
#     fat   : $sp + 0
#     ----------------
#
#  mapa dos registradores
#  ----------------------
#     k     : $t0
#     fat   : $t1
#  ----------------------
#
#  O código apresentado a seguir pode ser otimizado
################################################################################
# prologo
            addiu $sp, $sp, -8      # ajusta a pilha para os elementos k e fat
# corpo do procedimento
            # k = 5
            addiu $t0, $zero, 5     # k = $t0 <-5;
            sw    $t0, 4($sp)       # k = 5;
            # ajusta os parâmetros e chama a função
            add   $a0, $zero, $t0   # a0 <- k, a0 é argumento da função
            jal   fatorial          # chama a função fatorial
            # restaura o valor de $t0 = k
            lw    $t0, 4($sp)       # restaura o valor de k
            # atualiza o valor de fat
            addu  $t1, $zero, $v0   # $t1 = fat <- fatorial(k)
            sw    $v0, 0($sp)       # fat = fatorial(k)
            # imprime o valor de k e o fatorial de k
            # vamos usar uma função simplificada para printf("O fatorial de %d é %d\n",k, fat);
            # equivalente a printf_simplificada(k, fat);
            addu  $a0, $zero, $t0   # ajustamos os argumentos
            addu  $a1, $zero, $t1   #
            jal   printf            # imprimimos o resultado
            # Os valores de $t0 e $t1 são indeterminados aqui, após a chamada
            # ao procedimento. Não restauramos os valores porque não serão usados
            # novamente 
#epílogo
            addiu $sp, $sp, 8       # restaura a pilha
            # jr    $ra             # excepcionalmente para main terminamos o programa
# termina o programa
            addiu $v0, $zero, SERVICO_TERMINA_PROGRAMA # serviço 17 - término do programa: exit2
            addiu $a0, $zero, SUCESSO # resultado da execução do programa, 0: sucesso
            syscall                 # chamada ao sistema
# fim do procedimento main
################################################################################
    
    
    
################################################################################    
fatorial:
#------------------------------------------------------------------------------
# procedimento fatorial - retorna o fatorial de um inteiro
# n deve ser maior ou igual a zero
# n deve ser menor que 12 para registradores de 32 bits
#
# int fatorial(int n)
# {     
#     if(n==0) return 1;     
#     else return n*fatorial(n-1); 
# }
#------------------------------------------------------------------------------
#     mapa da pilha
#    ---------------
#    $ra   : $sp + 4
#    $a0   : $sp + 0
#    ---------------
#
################################################################################
# prólogo
            addiu $sp, $sp, -8      # ajusta a pilha para receber 2 itens
            sw    $ra, 4($sp)       # salva o endereço de retorno
            sw    $a0, 0($sp)       # salva o argumento da função
# corpo do procedimento
            bne   $zero, $a0, n_nao_igual_0 # se n!=0  calcule n*fatorial(n-1)
n_igual_0:
            add   $v0, $zero, 1     # retorna 1 = 0!
            j fatorial_epilogo      # epílogo  do procedimento
n_nao_igual_0:
            # precisamos retornar n* fatorial(n-1)
            # n está na pilha
            # calculamos fatorial(n-1)
            addi  $a0, $a0, -1      # a0 <- n-1
            jal   fatorial          # chamamos fatorial(n-1)
            lw    $a0, 0($sp)       # a0 <- n, restauramos n
            mul   $v0, $a0, $v0     # v0 <- n*fatorial(n-1), v0 valor de retorno
            lw    $ra, 4($sp)       # restaura o endereço de retorno
# epílogo
fatorial_epilogo:
            add   $sp, $sp, 8       # restaura a pilha - eliminamos 2 itens
            jr    $ra               # retorna para o procedimento chamador
# fim do procedimento fatorial
################################################################################    
    
    

################################################################################  
printf:
#    mapa da pilha
#  ------------------
#   $a0   : $sp + 0
#  ------------------
#
# Comentários:
#             Esta função foi simplificada. No exercicio063 apresentamos um 
#             código melhor
#
################################################################################
# prólogo
            addiu   $sp, $sp, -4
# corpo do procedimento
    # imprimimos a mensagem "O fatorial de"
            sw      $a0, 0($sp)     # guardamos na pilha $a0 = k
            addiu   $v0, $zero, SERVICO_IMPRIME_STRING # serviço 4: imprime uma string
            la      $a0, str0_0     # $a0 <- endereço da string 
            syscall                 # chamada ao serviço do sistema
            # imprimimos k
            lw      $a0, 0($sp)     # $a0 <- k, carregamos da pilha
            addiu   $v0, $zero, SERVICO_IMPRIME_INTEIRO # serviço 1: imprime um inteiro
            syscall                 # chamada ao serviço do sistema
            # imprimimos " é "
            la      $a0, str0_1     # $a0 <- endereço da string
            addiu   $v0, $zero, SERVICO_IMPRIME_STRING # serviço 4: imprime uma string
            syscall                 # chamada ao serviço do sistema
            # imprimimos fat
            move    $a0, $a1        # $a0 <- fat
            addiu   $v0, $zero, SERVICO_IMPRIME_INTEIRO # serviço 1: imprime um inteiro
            syscall                 # chamada ao serviço do sistema
            # imprimimos um fim de linha
            addiu   $a0, $zero, '\n' # $a0 <- fim de linha
            addiu   $v0, $zero, SERVICO_IMPRIME_CARACTERE # serviço 11: imprime um caracter
            syscall
#epílogo
            addiu   $sp, $sp, 4
            # retornamos ao procedimento chamador
            jr      $ra
################################################################################ 
   
    
################################################################################            
# Dados estáticos do programa        
#------------------------------------------------------------------------------
.data
    str0_0: .asciiz "O fatorial de "
    str0_1: .asciiz " é "    
################################################################################    
