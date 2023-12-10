.macro li.d (%register, %constant)
.data
    constant: .double %constant

.text
    ldc1 %register, constant
.end_macro

.data
    str_question: .asciiz "Digite o angulo em graus: "
    str_cosine: .asciiz "cos(x) = "
    str_sine: .asciiz "sen(x) = "
    
    PI: .double 3.1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679821480865132823066470938446095505822317253594081284811174502841027019385211055596446229489549303819644288109756659334461284756482337867831652712019091456485669234603486104543266482133936072602491412737245870066063155881748815209209628292540917153643678925903600113305305488204665213841469519415116094330572703657595919530921861173819326117931051185480744623799627495673518857527248912279381830119491298336733624406566430860213949463952247371907021798609437027705392171762931767523846748184676694051320005681271452635608277857713427577896091736371787214684409012249534301465495853710507922796892589235420199561121290219608640344181598136297747713099605187072113499999983729780499510597317328160963185950244594553469083026425223082533446850352619311881710100031378387528865875332083814206171776691473035982534904287554687311595628638823537875937519577818577805321712268066130019278766111959092164201989380952572010654858632788659361533818279682303019520353018529689957736225994138912497217752834791315155748572424541506959508295331168617278558890750983817546374649393192550604009277016711390098488240128583616035637076601047101819429555961989467678374494482553797747268471040475346462080466842590694912933136770289891521047521620569660240580381501935112533824300355876402474964732639141992726042699227967823547816360093417216412199245863150302861829745557067498385054945885869269956909272107975093029553211653449872027559602364806654991198818347977535663698074265425278625518184175746728909777727938000816470600161452491921732172147723501414419735685481613611573525521334757418494684385233239073941433345477624168625189835694855620992192221842725502542568876717904946016534668049886272327917860857843838279679766814541009538837863609506800642251252051173929848960841284886269456042419652850222106611863067442786220391949450471237137869609563643719172874677646575739624138908658326459958133904780275900994657640789512694683983525957098258226205224894077267194782684826014769909026

.text
main:
    la $a0, str_question                                    # $a0 = endereço para a mensagem de pergunta
    jal printstr                                            # imprime a mensagem de pergunta
    
    jal readdouble                                          # le um valor double

    mov.d $f12, $f0                                         # $f12 = angulo em graus lido
    jal deg2rad                                             # converte o angulo em graus para radianos

    mov.d $f12, $f0                                         # $f12 = x = angulo em radianos
    jal cos                                                 # calcula o cos(x)
    
    mov.d $f20, $f0                                         # $f20 = cos(x)

    la $a0, str_cosine                                      # $a0 = endereço para a mensagem de resultado
    jal printstr                                            # imprime a mensagem de resultado
     
    mov.d $f12, $f20                                        # $f12 = cos(x)
    jal printdouble                                         # imprime cos(x)
    jal println                                             # imprime uma nova linha    

    li.d ($f4, 1.0)                                         # $f4 = 1.0

    la $a0, str_sine                                        # $a0 = endereço para a mensagem de resultado
    jal printstr                                            # imprime a mensagem de resultado  

    mul.d $f12, $f20, $f20                                  # $f12 = cos^2(x)
    sub.d  $f12, $f4, $f12                                  # $f12 = 1 - cos^2(x)
    sqrt.d $f12, $f12                                       # $f12 = sqrt(1 - cos^2(x))

    jal printdouble                                         # imprime sen(x)
    jal println                                             # imprime uma nova linha    

    jal exit                                                # encerra o programa                 

# Converte um angulo em graus para radianos.
#
# argumentos:
# $f12 : angulo em graus
#
# retorno:
# $f0 : angulo em radianos
deg2rad:
    ldc1 $f4, PI                                            # carrega a constante PI
    li.d($f6, 180.0)                                        # carrega o valor de 180.0

    mul.d $f0, $f12, $f4                                    # deg * PI
    div.d $f0, $f0, $f6                                     # deg * PI / 180 

    jr $ra                                                  # retorna ao chamador

# Calcula cos(x).
#
# argumentos:
# $f12 : x = angulo em radianos
#
# retorno:
# $f0 : cos(x)
#
# mapa dos registradores:
# $t0  : iteração
# $f0  : resultado
# $f4  : 1
# $f6  : x^2
# $f8  : n
# $f10 : termo
cos:
    li.d($f0, 1.0)                                          # $f0 = 1
    li.d($f4, 1.0)                                          # $f4 = 1
    li.d($f8, 1.0)                                          # $f8 = 1
    li.d($f10, 1.0)                                         # $f10 = 1

    li $t0, 7                                               # $t0 = 7

    mul.d $f6, $f12, $f12                                   # $f6 = x^2

    loop:
        neg.d $f10, $f10                                    # termo = -termo

        mul.d $f10, $f10, $f6                               # termo = termo * x^2

        div.d $f10, $f10, $f8                               # termo = termo / n
        add.d $f8, $f8, $f4                                 # n += 1

        div.d $f10, $f10, $f8                               # termo = termo / n
        add.d $f8, $f8, $f4                                 # n += 1

        add.d $f0, $f0, $f10                                # resultado = resultado + termo

        addi $t0, $t0, -1                                   # decrementa o contador de interações
        bnez $t0, loop                                      # enquanto o contador não for igual a zero, continua o loop

    jr $ra                                                  # retorna ao chamador

# Le um double do usuário.
#
# retorno:
# $f0 : double digitado
readdouble:
    li $v0, 7                                               # serviço 7: le double
    syscall                                                 # realiza uma chamada ao sistema 

    jr $ra                                                  # retorna ao chamador

# Imprime um double.
#
# argumentos:
# $f12 : double a ser impresso
printdouble:
    li $v0, 3                                               # serviço 3: imprime double
    syscall                                                 # realiza uma chamada ao sistema

    jr $ra                                                  # retorna ao chamador

# Imprime uma string.
#
# argumentos:
# $a0 : endereço para o texto com terminador nulo
printstr:
    li $v0, 4                                               # serviço 4: imprime texto
    syscall                                                 # realiza uma chamada ao sistema
    
    jr $ra                                                  # retorna ao chamador
    
println:
    li $v0, 11                                              # serviço 11: imprime caractere
    li $a0, '\n'                                            # $a0 = nova linha
    syscall                                                 # realiza uma chamada ao sistema

    jr $ra                                                  # retorna ao chamador

# Encerra o programa.
exit:
    li $v0, 10                                              # serviço 10: encerra o programa
    syscall                                                 # realiza uma chamada ao sistema
    
    jr $ra                                                  # retorna ao chamador
