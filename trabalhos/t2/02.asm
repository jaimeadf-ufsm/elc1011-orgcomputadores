.eqv        SERVICO_IMPRIME_STRING      4
.eqv        SERVICO_TERMINA_PROGRAMA    10
.eqv        SERVICO_IMPRIME_DOUBLE      3
.eqv        SERVICO_LE_DOUBLE           7

.macro li.d (%register, %constant)
.data
constant: .double %constant
.text
ldc1 %register, constant
.end_macro


main:

    la $a0, msg_pergunta
    jal imprime_string                          # Imprime a mensagem de pergunta

    jal ler_angulo  

    mov.d $f12, $f0
    jal converter_graus_para_radianos           # Angulo em graus eh convertido pra radianos

    mov.d $f12, $f0
    jal calcular_cos                            # Calcula cos
    s.d $f0, cosx                               # Guarda valor de $f0 (cosx) em cosx

    la $a0, msg_resultado1
    jal imprime_string
    ldc1  $f12, cosx 
    jal imprime_double                          # Imprime cosx    

    ldc1  $f0, cosx                             # $f0 = cosx
    li.d($f2, 1.0)                              #  
    mul.d $f0, $f0, $f0                         # $f0 = $f0^2
    sub.d $f0, $f2, $f0                         # $f0 = 1-$f0^2
    sqrt.d $f0, $f0                             # $f0 = sqrt(1-$f0^2)

    s.d $f0, senx                               # Guarda valor de $f0 (senx) em senx

    la $a0, msg_resultado2
    jal imprime_string                          
    ldc1  $f12, senx 
    jal imprime_double                          # Imprime senx

    j fim                                       # Termina programa


################################################
# Retorno:
# $f0 -> angulo lido
################################################
ler_angulo:
    li $v0, SERVICO_LE_DOUBLE
    syscall                  
    jr $ra

################################################
# Argumentos:
# $f12 -> angulo em graus
# Retorno:
# $f0 -> angulo em radianos
################################################
converter_graus_para_radianos:
    ldc1 $f0, PI                                # Carrega a constante PI
    li.d($f2, 180.0)                            # Carrega o valor 180.0

    mul.d $f12, $f12, $f0                       # Multiplica o valor em $f12 por $f0
    div.d $f12, $f12, $f2                       # Divide o valor em $f12 por $f2
    mov.d $f0, $f12                             # Move o resultado para $f0
    jr $ra                                      # Retorna

################################################
# Argumentos:
# $f12 -> x = angulo em radianos
# Retorno:
# $f0 -> cos(x)
################################################
################################################
# Mapa dos registradores
# $f0 = resultado
# $f4 = 1
# $f6 = x^2
# $f8 = n
# $f10 = termo atual
# $t0 = iteração
################################################
calcular_cos:
    li.d($f0, 1.0)                               # $f0 = 1
    li.d($f4, 1.0)                               # $f4 = 1
    li.d($f8, 1.0)                               # $f8 = 1
    li.d($f10, 1.0)                              # $f10 = 1
    li $t0, 7                                    # $t0 = 7

    mul.d $f6, $f12, $f12                        # $f6 = x^2

    loop:
        neg.d $f10, $f10                         # $f10 = -$f10

        mul.d $f10, $f10, $f6                    # $f10 = $f10 * $f6

        div.d $f10, $f10, $f8                    # $f10 = $f10 / $f8
        add.d $f8, $f8, $f4                      # $f8 = $f8 + $f4

        div.d $f10, $f10, $f8                    # $f10 = $f10 / $f8
        add.d $f8, $f8, $f4                      # $f8 = $f8 + $f4

        add.d $f0, $f0, $f10                     # $f0 = $f0 + $f10

        addi $t0, $t0, -1                        # $t0 = $t0 - 1
        bnez $t0, loop                           # if ($t0 != 0) -> loop
    jr $ra

################################################
# Argumentos:
# $f12 -> double a ser impresso
################################################
imprime_double:
    li $v0, SERVICO_IMPRIME_DOUBLE               
    syscall
    li $v0, SERVICO_IMPRIME_STRING  
    la $a0, nova_linha
    syscall
    jr $ra             

################################################
# Argumentos:
# $a0 -> string a ser impressa
################################################
imprime_string:             
    li $v0, SERVICO_IMPRIME_STRING              
    syscall          
    jr $ra          

fim:
    li $v0, SERVICO_TERMINA_PROGRAMA
    syscall

.data

    msg_pergunta: .asciiz "Digite o angulo em graus: "
    msg_resultado1: .asciiz "O cosseno do angulo ?: "
    msg_resultado2: .asciiz "O seno do angulo ?: "
    nova_linha:    .asciiz "\n"
    PI: .double 3.1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679821480865132823066470938446095505822317253594081284811174502841027019385211055596446229489549303819644288109756659334461284756482337867831652712019091456485669234603486104543266482133936072602491412737245870066063155881748815209209628292540917153643678925903600113305305488204665213841469519415116094330572703657595919530921861173819326117931051185480744623799627495673518857527248912279381830119491298336733624406566430860213949463952247371907021798609437027705392171762931767523846748184676694051320005681271452635608277857713427577896091736371787214684409012249534301465495853710507922796892589235420199561121290219608640344181598136297747713099605187072113499999983729780499510597317328160963185950244594553469083026425223082533446850352619311881710100031378387528865875332083814206171776691473035982534904287554687311595628638823537875937519577818577805321712268066130019278766111959092164201989380952572010654858632788659361533818279682303019520353018529689957736225994138912497217752834791315155748572424541506959508295331168617278558890750983817546374649393192550604009277016711390098488240128583616035637076601047101819429555961989467678374494482553797747268471040475346462080466842590694912933136770289891521047521620569660240580381501935112533824300355876402474964732639141992726042699227967823547816360093417216412199245863150302861829745557067498385054945885869269956909272107975093029553211653449872027559602364806654991198818347977535663698074265425278625518184175746728909777727938000816470600161452491921732172147723501414419735685481613611573525521334757418494684385233239073941433345477624168625189835694855620992192221842725502542568876717904946016534668049886272327917860857843838279679766814541009538837863609506800642251252051173929848960841284886269456042419652850222106611863067442786220391949450471237137869609563643719172874677646575739624138908658326459958133904780275900994657640789512694683983525957098258226205224894077267194782684826014769909026
    cosx: .double 0
    senx: .double 0
