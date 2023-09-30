.include "constants.asm"

.eqv READ_BUFFER_SIZE 1024
.eqv WRITE_BUFFER_SIZE 1024

.text

.globl main
main:
    la $a0, input_filename                                 # $a0 = <endereço> para o nome do arquivo de entrada 
    li $a1, 0                                              # $a1 = 0 (flag para leitura)
    jal openfile                                           # abre o arquivo

    la $t0, input_descriptor                               # $a0 = <endereço> onde será armazenado o descritor do arquivo
    sw $v0, 0($t0)                                         # armazena o descritor do arquivo de entrada       

    la $a0, output_filename                                # $a0 = <endereço> para o nome do arquivo de saída 
    li $a1, 0                                              # $a1 = 1 (flag para escrita)
    jal openfile                                           # abre o arquivo

    la $t0, output_descriptor                              # $a0 = <endereço> onde será armazenado o descritor do arquivo
    sw $v0, 0($t0)                                         # armazena o descritor do arquivo de saída       

    j main_read_while_condition                            # verifica se o arquivo ainda possui bytes para serem processados

main_read_while_loop:
    move $a0, $v0                                          # $a0 = número de bytes lidos                                     
    jal decodeinsts                                        # decodifica as instruções no buffer de entrada
    
main_read_while_condition:
    la $t0, input_descriptor                               # $t0 = <endereço> para o descritor do arquivo de entrada

    lw $a0, 0($t0)                                         # $a0 = descritor do arquivo de entrada
    la $a1, read_buffer                                    # $a1 = <endereço> onde será armazenado os bytes lidos
    li $a2, READ_BUFFER_SIZE                               # $a2 = capacidade máxima de bytes que podem serem lidos
    jal readfile                                           # lê o arquivo de entrada

    bgtz $v0, main_read_while_loop                  # se o número de bytes lidos for maior que zero, continua o loop

    la $t0, input_descriptor                               # $t0 = <endereço> para o descritor do arquivo de entrada
    lw $a0, 0($t0)                                         # $a0 = descritor do arquivo de entrada
    jal closefile                                          # fecha o arquivo

    la $t0, output_descriptor                              # $t0 = <endereço> para o descritor do arquivo de saída
    lw $a0, 0($t0)                                         # $a0 = descritor do arquivo de saída
    jal closefile                                          # fecha o arquivo

    jal exit                                               # encerra o programa


# Decodifica o bloco de instruções no buffer de leitura.
# 
# argumentos:
# $a0 : <word> número de bytes para processar
#
# pilha:
# $sp +  8 : $s1
# $sp +  4 : $s0
# $sp +  0 : $ra
decodeinsts:
    addiu $sp, $sp, -12                                    # ajusta a pilha
    sw $s1, 8($sp)                                         # armazena na pilha o registrador $s1
    sw $s0, 4($sp)                                         # armazena na pilha o registrador $s0
    sw $ra, 0($sp)                                         # armazena na pilha o endereço de retorno

    la $s0, read_buffer                                    # $s0 = <endereço> para o início do buffer de leitura
    addu $s1, $s0, $a0                                     # $s1 = <endereço> para o fim do buffer de leitura

    j decodeinst_for_condition                             # vai para a condição do loop

decodeinst_for_loop:
    la $t0, program_counter                                # $t0 = <endereço> para o PC
    lw $a1, 0($t0)                                         # $a1 = PC

    addiu $t1, $a1, 4                                      # $t1 = PC + 4 (endereço da próxima instrução)
    sw $t1, 0($t0)                                         # armazena o endereço da próximo instrução em PC

    la $a0, dinst                                          # $a0 = <endereção> para a estrutura de instrução decodificada
    lw $a2, 0($s0)                                         # $a2 = código de máquina a ser decodificado                                       
    jal decodeinst                                         # decodifica a instrução

    jal writeinst                                          # escreve a instrução no arquivo

decodeinst_for_increment:
    addiu $s0, $s0, 4                                      # incrementa o endereço do buffer de leitura para a próxima instrução

decodeinst_for_condition:
    blt $s0, $s1, decodeinst_for_loop                      # se o endereço atual for menor que o endereço final, continua o loop

    lw $s1, 8($sp)                                         # restaura o registrador $s1
    lw $s0, 4($sp)                                         # restaura o registrador $s0
    lw $ra, 0($sp)                                         # restaura o endereço de retorno
    addiu $sp, $sp, 12                                     # restaura a pilha

    jr $ra                                                 # retorna ao chamador


# Escreve a instrução decodifica para o arquivo de saída.
#
writeinst:
    addiu $sp, $sp, -4                                     # ajusta a pilha
    sw $ra, 0($sp)                                         # armazena na pilha o endereço de retorno

    la $t0, dinst_address                                  # $t0 = <endereço> para a posição da instrução decodificada

    la $a0, write_buffer                                   # $t0 = <endereço> para o buffer de escrita
    lw $a1, 0($t0)                                         # $a1 = posição da instrução decodificada para ser escrito
    jal itostrhex                                          # escreve a posição em hexadecimal na string de saída

    li $t2, ' '                                            # $t2 = espaço
    sb $t2, 0($v0)                                         # escreve um espaço após a posição

    la $t0, dinst_code                                     # $t0 = <endereço> para o código de máquina da instrução decodificada

    addiu $a0, $v0, 1                                      # $a0 = <endereço> para o final atual da string de saída
    lw $a1, 0($t0)                                         # $a1 = código da instrução decodificada para ser escrito
    jal itostrhex                                          # escreve o código em hexadecimal na string de saída

    li $t2, ' '                                            # $t2 = espaço
    sb $t2, 0($v0)                                         # escreve um espaço após o código de máquina 

    la $t0, dinst_definition                               # $t0 = <endereço> para o <endereço> da definição da instrução
    lw $t1, 0($t0)                                         # $t1 = <endereço> para a definição da instrução

    addiu $a0, $v0, 1                                      # $a0 = <endereço> para o final atual da string de saída

    beq $t1, $zero, writeinst_if_unknown_inst              # verifica se a instrução é conhecida

writeinst_if_not_unknown_inst:
    lw $a1, 16($t1)                                        # $a1 = <endereço> para a string de formatação da instrução
    la $a2, dinst_operands                                 # $a2 = <endereço> para o vetor de <Operando>
    jal strfmt                                             # formata a instrução para uma string

    j writeinst_if_unknown_inst                            # vai para fora do bloco if
    
writeinst_if_unknown_inst:
    la $a1, str_unknown_inst                               # $a1 = <endereço> para a string de instrução desconhecida
    jal strcpy                                             # copia a string de instrução desconhecida para a string de saída
    
writeinst_end_if_unknown_inst:
    li $t2, '\n'                                           # $t2 = nova linha
    sb $t2, 0($v0)                                         # escreve uma nova linha após a instrução

    la $t0, output_descriptor                              # $t0 = <endereço> para o descritor do arquivo de saída

    lw $a0, 0($t0)                                         # $a0 = descritor do arquivo de saída
    la $a1, write_buffer                                   # $a1 = <endereço> para o início do buffer de saída
    subu $a2, $v0, $a1                                     # $a2 = tamanho da string para ser escrita
    addiu $a2, $a2, 1                                      # inclui o caractere nova linha no tamanho
    jal writetofile                                        # escreve para o arquivo de saída

    lw $ra, 0($sp)                                         # restaura o endereço de retorno
    addiu $sp, $sp, 4                                      # restaura a pilha

    jr $ra                                                 # retorna ao chamador



# Abre um determinado arquivo.
#
# argumentos:
# $a0 : <endereço> string com o nome do arquivo
# $a1 : <word> flags (0: leitura, 1: escrita)
# 
# retorno:
# $v0 : <word> descritor do arquivo
openfile:
    li $v0, 13                                             # serviço 13: abre um arquivo
    li $a2, 0                                              # $a2 = modo = 0 (parâmetro ignorado)
    syscall                                                # realiza uma chamada ao sistema

# Fecha o arquivo.
#
# argumentos:
# $a0 : <word> descritor do arquivo
closefile:
    li $v0, 16                                             # serviço 16: fechar arquivo
    syscall                                                # realiza uma chamada ao sistema


# Lê um bloco de n bytes do arquivo.
#
# argumentos:
# $a0 : <word> descritor do arquivo
# $a1 : <endereço> para o buffer de leitura
# $a1 : <word> número de bytes para serem lidos
#
# retorno:
# $v0 : <word> número de bytes lidos (negativo se ocorrer um erro)
readfile:
    li $v0, 14                                             # serviço 14: ler de um arquivo
    syscall                                                # realiza uma chamada ao sistema

# Escreve um texto terminado com nulo no arquivo.
#
# argumentos:
# $a0 : <word> descritor de arquivo
# $a1 : <endereço> para o buffer de saída
# $a2 : <word> número de bytes para escrever
writetofile:
    li $v0, 15                                             # serviço 15: escreve em um arquivo
    syscall                                                # realiza a chamada de sistema


# Encerra o program.
exit:
    li $v0, 17
    li $a0, 0
    syscall

.data
input_filename:  .asciiz "object.bin"
output_filename: .asciiz "assembly.txt"

input_descriptor:  .word 0
output_descriptor: .word 0

read_buffer:   .space READ_BUFFER_SIZE
write_buffer: .space WRITE_BUFFER_SIZE

program_counter: .word 0x00400000

dinst:
dinst_address:    .word 0
dinst_code:       .word 0
dinst_definition: .word 0
dinst_operands:   .word 0, 0, 0, 0, 0, 0, 0, 0

str_unknown_inst: .asciiz "instrucao desconhecida"
