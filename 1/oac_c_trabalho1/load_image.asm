#-------------------------------------------------------------------------
#		Organiza√ß√£o e Arquitetura de Computadores - Turma C 
#			Trabalho 1 - Assembly RISC-V
#
# Nome: Anne 				Matr√≠cula: 
# Nome: Gabriel				Matr√≠cula: 
# Nome: Wellington Stanley				Matr√≠cula: 11/0143981

.data

	str_enter:	.string "\n"
	str_valor_r:	.string "Valor de R: "
	str_valor_g:	.string "Valor de G: "
	str_valor_b:	.string "Valor de B: "
	str_menu:   	.string "Digite a opÁ„o desejada:\n 1 - get_point\n 2 - draw_point\n 3 - draw_full_rectangle\n 4 - draw_empty_rectangle\n 5 ñ convert_negative\n 6 - convert_redtones\n 7 - load_image\n 8 - sair\n"	
	str_opcao_1:   	.string "Informe os valores de x e y separados por enter:\n"
	str_opcao_3_4:  .string "Informe os valores de xi, yi, xf, yf separados por enter:\n"
	
	image_name:   	.asciz "lenaeye.raw"	# nome da imagem a ser carregada
	address: 	.word   0x10040000	# endereco do bitmap display na memoria	
	buffer:		.word   0		# configuracao default do RARS
	size:		.word	4096		# numero de pixels da imagem

.text
	#-------------------------------------------------------------------------
	# FunÁ„o get_point: carrega um ponto a partir de uma coordenada informada
	# pelo usu·rio, retornando assim os valores R, G e B em hexadecimal na
	# saÌda padr„o.
	#
	# Parametros:
	#  $x: inteiro, coordenada do eixo vertical, ou seja, indica qual coluna
	#  $y: inteiro, coordenada do eixo horizontal, ou seja, indica qual linha
	#
	# A funÁ„o recebe os dois parametros que s„o o par ordenado x,y que juntos
	# indicam a localizaÁ„o do ponto desejado. … feita uma multiplicaÁ„o por
	# 4 no x e por 256 no y usando ssli. ApÛs isso, tanto o x quanto o y s„o
	# adicionados ao endereÁo base da heap para, assim, encontrar o ponto com
	# exatid„o e em seguida carreg·-lo em uma word. Posteriormente, 1 byte ser·
	# carregado por vez: R, G e B, respectivamente, pela instruÁ„o. O R È o 
	# terceiro byte e por isso tem 2 adicionado ao endereÁo base da word, e para
	# sua exibiÁ„o em hexadecimal h· um shift para a esquerda de 16 bits. O mesmo 
	# ocorre com o G mas, por ser o segundo byte, tem 1 adicionado ao endereÁo 
	# base e para hexadecimal um shitf para a esquerda de 8 bits. O B j· est· em 
	# conformidade. Por fim, s„o exibidos os valores R, G e B em hexadecimal. 
	.macro get_point($x, $y)
		li	t1, 63		#como o display È invertido o calculo para y's ser· 63-y
		sub	t1, t1, $y	#63-y = posicao da linha informada
		slli 	t0, $x, 2  	#posicao X x 4 = coordenada dada para coluna
		slli 	t1, t1, 8  	#posicao Y x 256 = coordenada dada para linha

		add 	t2, zero, t1	#calcular linha t2 = Y x 256
		add 	t2, t2, t0	#calcular coluna t2 = (X x 4) + Y x 256
		lw 	a1, address	#endereÁo base heap para a1
		
		add 	t2, t2, a1	#posicao do ponto xy = endereÁo base + t2
		
		lw 	t1, 0(t2)	#carrega o conteudo = o ponto xy na heap para t1
		mv	a0, t1		#conte˙do do ponto para a0
		li	a7, 34		#imprime o valor hex RGB do ponto
		ecall
		
		li	a7, 4
		la	a0, str_enter	#imprime quebra de linha
		ecall

		li	a7, 4
		la	a0, str_valor_r #imprime texto de valor do R:
		ecall
		
		lbu  	t1, 2(t2)	#carrega o 3 byte=R com extensao de 0's a esquerda para t1
		slli 	t1, t1, 16	#move o byte para a posicao 16-23, por exemplo, de 0x000000FF para 0x00FF0000
		mv 	a0, t1
		li	a7, 34		#imprime o valor hex de R
		ecall
		
		li	a7, 4
		la	a0, str_enter	#imprime quebra de linha
		ecall

		li	a7, 4
		la	a0, str_valor_g	#imprime o texto de valor do G:
		ecall
				
		lbu  	t1, 1(t2)	#carrega o 2 byte=G com extensao de 0's a esquerda para t1
		slli 	t1, t1, 8	#move o byte para a posicao 8-15, por exemplo, de 0x000000FF para 0x000FF00
		mv 	a0, t1
		li	a7, 34		#imprime o valor hex de G
		ecall
		
		li	a7, 4
		la	a0, str_enter	#imprime quebra de linha
		ecall
		
		li	a7, 4
		la	a0, str_valor_b	#imprime o texto de valor de B
		ecall
		
		lbu 	t1, 0(t2)	#carrega o 1 byte=B com extensao de 0's a esquerda para t1
		mv 	a0, t1
		li	a7, 34		#imprime o valor hex de B
		ecall
		
		li	a7, 4
		la	a0, str_enter	#imprime quebra de linha
		ecall
		
		#	zerando registradores tempor·rios +- clean
		li	t0, 0
		li	t1, 0
		li	t2, 0
		
		j main
	.end_macro
	
	.macro draw_point($x, $y, $val)
		li	t1, 63		#como o display È invertido o calculo para y's ser· 63-y
		sub	t1, t1, $y	#63-y = posicao da linha informada
		slli 	t0, $x, 2  	#posicao X x 4 = coordenada dada para coluna
		slli 	t1, t1, 8  	#posicao Y x 256 = coordenada dada para linha

		add 	t2, t2, t1	#calcular linha t3 = X x 4
		add 	t2, t2, t0	#calcular coluna t3 = (X x 4) + Y x 256
		lw 	a1, address	#endereÁo base heap para a1
		
		add 	t2, t2, a1	#posicao xy = endereÁo base + t2
		sw 	$val, 0(t2)	#armazena o conteudo RGB informado no ponto xy do display
		
		#	zerando registradores tempor·rios +- clean
		li	t0, 0
		li	t1, 0
		li	t2, 0
		
		j	main
	.end_macro
	
	.macro draw_full_rectangle($xi, $yi, $xf, $yf, $val)
		add	s0, zero, $xi
		add	s1, zero, $yi
		add	s2, zero, $xf
		add	s3, zero, $yf
		add	s4, zero, $val
		li	s5, 63		#como o display È invertido o calculo para y's ser· 63-y
		
		sub	s1, s5, s1	#linha mais acima 63-yi = faz a coordenada yi ficar de acordo com o display 0 a 63
		sub	s3, s5, s3	#linha mais abaixo 63-yf = faz a coordenada yf ficar de acordo com o display 0 a 63
		
		slli 	t0, $xi, 2  	#posicao X x 4 = coordenada dada para coluna do ponto a direita
		slli 	t1, s1, 8  	#posicao Y x 256 = coordenada dada para linha superior
		slli 	t2, $xf, 2  	#posicao X x 4 = coordenada dada para coluna do ponto a esquerda
		slli 	t3, s3, 8  	#posicao Y x 256 = coordenada dada para linha inferior

		add 	t0, t0, t1	##calcular ponto direito superior t0 = (xi x 4) + yi x 256
		add 	t1, t2, t3	#calcular ponto esquerdo inferior t1 = (xf x 4) + yf x 256
		lw 	a1, address	#endereÁo base heap para a1
		
		add 	t0, t0, a1	#posicao xiyi = endereÁo base + t0
		add 	t2, t1, a1	#posicao xfyf = endereÁo base + t1
		
		sub	a2, s0, s2	#n˙mero de colunas que ser„o preenchidas
		sub	a3, s3, s1	#n˙mero de linhas que ser„o preenchidas
		addi	a2, a2, 1	#o total de colunas vai de 0 a X+1
		addi 	a3, a3, 1	#o total de linhas vai de 0 a Y+1
		
		mul  	t1, a2,	a3	#n˙mero de iteraÁıes para preenchimento Xi colunas x Yi linhas 
		mv	t2, t0		#copia o endereÁo do ponto superior direito para t2
		li	t3, 0

		draw_full_rectangle:
			beq 	t1, zero, clear	# se todo a area foi preenchida retorna para o menu
			sw 	s4, 0(t2)	#armazena o conteudo RGB informado no ponto xy do display
			addi	t2, t2, -4	#prÛximo pixel a esquerda para ser preenchido
			addi	t1, t1, -1	#decrementa a quantidade de iteraÁıes= n˙mero de pontos xy
			addi	t3, t3, 1	#controla quantas colunas deve preencher por iteraÁ„o
			blt	t3, a2, draw_full_rectangle #enquanto as iteraÁıes de coluna n„o finaliza, preencha o retangulo 
			li	t3, 0		#zera o contador de iteraÁıes para a prÛxima linha
			addi	t0, t0, 256	#endereÁo base + 256 = prÛxima linha
			mv	t2, t0		

			j 	draw_full_rectangle
	.end_macro
	
	.macro draw_empty_rectangle($xi, $yi, $xf, $yf, $val)
		add	s0, zero, $xi
		add	s1, zero, $yi
		add	s2, zero, $xf
		add	s3, zero, $yf
		add	s4, zero, $val
		li	s5, 63		#como o display È invertido o calculo para y's ser· 63-y
		
		sub	s1, s5, s1	#linha mais abaixo 63-yi = faz a coordenada yi ficar de acordo com o display 0 a 63
		sub	s3, s5, s3	#linha mais abaixo 63-yf = faz a coordenada yf ficar de acordo com o display 0 a 63
		
		slli 	t0, $xi, 2  	#posicao X x 4 = coordenada dada para coluna do ponto a esquerda
		slli 	t1, s1, 8  	#posicao Y x 256 = coordenada dada para linha inferior
		slli 	t2, $xf, 2  	#posicao X x 4 = coordenada dada para coluna do ponto a direita
		slli 	t3, s3, 8  	#posicao Y x 256 = coordenada dada para linha superior

		add 	t0, t0, t1	#calcular coluna t0 = (xi x 4) + yi x 256
		add 	t1, t2, t3	#calcular coluna t1 = (xf x 4) + yf x 256
		lw 	a1, address	#endereÁo base heap para a1
		
		add 	t0, t0, a1	#posicao xiyi = endereÁo base + t0
		add 	t2, t1, a1	#posicao xfyf = endereÁo base + t1
		
		sub	a2, s2, s0	#n˙mero de colunas que ser„o preenchidas
		sub	a3, s1, s3	#n˙mero de linhas que ser„o preenchidas
		slli	s1, a2, 2	#numero de colunas x 4 bytes representar· cada ponto vertical esquerdo
		addi	a2, a2, 1	#o total de colunas vai de 0 a X+1
		addi 	a3, a3, 1	#o total de linhas vai de 0 a Y+1
		
		mv  	t1, a3		#n˙mero de iteraÁıes para preenchimento de Y linhas 
		mv	t0, t2		#copia o endereÁo do ponto superior direito para t2
		mv	t3, a2
		li	s0, 1

		draw_empty_rectangle:
			beq 	t1, zero, clear	# se toda o contorno for preenchido retorna para o menu
			beq	t1, a3, draw_full_line #se esta na primeira linha t1=a3, preenche toda linha
			sw 	s4, 0(t2)	#armazena o conteudo RGB informado no ponto xy da borda mais a direita
			sub	t2, t2, s1	#prÛximo pixel a esquerda para ser preenchido
			sw	s4, 0(t2)	#armazena o conteudo RGB informado no ponto xy da borda mais esquerda 
			addi	t1, t1, -1	#decrementa a quantidade de iteraÁıes= n˙mero de pontos xy
			addi	t0, t0, 256	#endereÁo base + 256 = prÛxima linha
			mv	t2, t0		#t2=t0
			beq	t1, s0, draw_full_line #se esta na ultima linha t1=s0, preenche toda linha
					
			j	draw_empty_rectangle
		
		draw_full_line:
			sw 	s4, 0(t2)	#armazena o conteudo RGB informado no ponto xy do display
			addi	t2, t2, -4	#prÛximo pixel a esquerda para ser preenchido
			addi	t3, t3, -1	#decrementa a quantidade de iteraÁıes= n˙mero de colunas
			bgt 	t3, zero, draw_full_line # se todo a area foi preenchida retorna para o menu
			mv	t3, a2		#t3= total de colunas para preencher outra linha em outro loop
			addi	t1, t1, -1	#decrementa a quantidade de iteraÁıes= n˙mero de pontos xy
			addi	t0, t0, 256	#t0 = endereÁo base + 256 = prÛxima linha
			mv	t2, t0		#t2= t0
			j	draw_empty_rectangle
			
	.end_macro
	
	#Fun√ß√£o que inverte as cores da imagem atrav√©s da subtra√ß√£o entre o valor 255 e os componentes RGB, retornando o negativo da mesma 
	.macro convert_negative()
		mv 	t1, a1	#t1=a1 copiar base da heap para t1
		convert_negative:
			beq 	a3, zero, close		#verifica se o contador de pixels da imagem chegou a 0
			lw	 t0, 0(t1)   		# l√™ pixel do display
			li	 t2, 255 		#Atribui o valor 255 ao t2 
			sub	 t0, t2, t0 		#t0 = t2 - t0 --> t0 = 255(que ÔøΩ transformado pra hexa pelo rars) - (hexadecimal do pixel atual)
			sw	 t0, 0(t1)   		# escreve pixel no display
			addi	 t1, t1, 4  		# pr√≥ximo pixel
			addi	 a3, a3, -1  		# decrementa countador de pixels da imagem
		
			j convert_negative
	.end_macro
	
	.macro convert_readtones()
		mv 	t1, a1	#t1=a1 copiar base da heap para t1
		
		#fun√ß√£o que converte para zero os componentes G e B do ponto, mantendo somente ativo o componente R
		convert_redtones:
			beq a3, zero, close		#verifica se o contador de pixels da imagem chegou a 0
			lw   t0, 0(t1)   		# l√™ pixel do display
			li t2, 0x00ff0000		#Atribui o hexadecimal da cor vermelha ao t2
			and t0, t2, t0 			#Faz um and bit a bit com o intuito de zerar todos os bits, menos os bits correspondentes a cor vermelha
			sw   t0, 0(t1)   		# escreve pixel no display
			addi t1, t1, 4  		# pr√≥ximo pixel
			addi a3, a3, -1  		# decrementa countador de pixels da imagem
		
			j convert_redtones
	.end_macro
	
	.macro load_image($image_name, $address, $buffer, $size)
		# salva os par√¢metros da fun√ßao nos tempor√°rios
		mv 	t0, $image_name	# nome do arquivo
		mv 	t1, $address	# endereco de carga
		mv 	t2, $buffer	# buffer para leitura de um pixel do arquivo
	
		# chamada de sistema para abertura de arquivo
		#par√¢metros da chamada de sistema: a7=1024, a0=string com o diret√≥rio da imagem, a1 = defini√ß√£o de leitura/escrita
		li 	a7, 1024	# chamada de sistema para abertura de arquivo
		li 	a1, 0		# Abre arquivo para leitura (pode ser 0: leitura, 1: escrita)
		ecall			# Abre um arquivo (descritor do arquivo √© retornado em a0)
		mv 	s0, a0		# salva o descritor do arquivo em s0
	
		mv 	a0, s0		# descritor do arquivo 
		mv 	a1, t2		# endere√ßo do buffer 
		li 	a2, 3		# largura do buffer

		#loop utilizado para ler pixel a pixel da imagem
		loop:  
		
			beq  	$size, zero, close	#verifica se o contador de pixels da imagem chegou a 0

			#chamada de sistema para leitura de arquivo
			#par√¢metros da chamada de sistema: a7=63, a0=descritor do arquivo, a1 = endere√ßo do buffer, a3 = m√°ximo tamanho pra ler
			li	a7, 63		# defini√ß√£o da chamada de sistema para leitura de arquivo 
			ecall            	# l√™ o arquivo
			lw	t3, 0(a1)	# l√™ pixel do buffer	
			sw	t3, 0(t1)   	# escreve pixel no display
			addi 	t1, t1, 4  	# pr√≥ximo pixel
			addi 	$size, $size, -1  	# decrementa countador de pixels da imagem
		
			j loop
	.end_macro
	
	main:	# o intuito È permanecer no menu atÈ o usuario digitar a opÁ„o 8
		jal exibe_menu
	
		li 	a7, 5		#a7=5 -> defini√ß√£o da chamada de sistema para ler opcao do usuario
		ecall			#realiza a chamada de sistema
		mv 	t0, a0
		
		#de acordo com a opcao informada pelo usuario alguma opcao ser· acionada	
		li	t1, 1
		beq 	t0, t1, opcao_1
		li 	t1, 2
		beq 	t0, t1, opcao_2
		li	t1, 3
		beq	t0, t1, opcao_3
		li	t1, 4
		beq	t0, t1, opcao_4
		li	t1, 5
		beq	t0, t1, opcao_5
		li	t1, 6
		beq	t0, t1, opcao_6
		li	t1, 7
		beq	t0, t1, opcao_7
		li 	t1, 8
		beq	t0, t1 sair
  	
  	sair:
		#defini√ß√£o da chamada de sistema para encerrar programa	
		#par√¢metros da chamada de sistema: a7=10
		li a7, 10		
		ecall

	
	# fecha o arquivo 
	close:
		# chamada de sistema para fechamento do arquivo
		#par√¢metros da chamada de sistema: a7=57, a0=descritor do arquivo
		li	a7, 57		# chamada de sistema para fechamento do arquivo
		mv 	a0, s0		# descritor do arquivo a ser fechado
		ecall		        # fecha arquivo
		#	zerando registradores tempor·rios +- clean
		li	t0, 0
		li	t1, 0
		li	t2, 0
		#retorna para o menu	
		j 	main
	
	exibe_menu:
		li	a7, 4		#a7=4 -> defini√ß√£o da chamada de sistema para imprimir strings na tela
		la	a0, str_menu	#a0=endere√ßo da string "str_menu"
		ecall			#realiza a chamada de sistema
		jr 	ra
		
	opcao_1:
		li	a7, 4		#chamada de sistema para imprimir string
		la	a0, str_opcao_1	#a0=endere√ßo da string
		ecall			#realiza a chamada de sistema
		
		li 	a7, 5		#chamada de sistema para ler x
		ecall			#chamada de sistema
		mv 	t0, a0		#t0=x
		
		li 	a7, 5		#chamada de sistema para ler y
		ecall			#chamada de sistema
		mv 	t1, a0		#t1=y
				
		get_point(t0, t1)
		
	opcao_2:
		li	a7, 4		#chamada de sistema para imprimir string
		la	a0, str_opcao_1	#a0=endere√ßo da string
		ecall			#realiza a chamada de sistema
		
		li 	a7, 5		#chamada de sistema para ler x
		ecall			#chamada de sistema
		mv 	a1, a0		#a1=x
		
		li 	a7, 5		#chamada de sistema para ler y
		ecall			#chamada de sistema
		mv 	a2, a0		#a2=y
		
		jal ler_valores_rgb

		draw_point(a1, a2, a3)
		
	opcao_3:
		#funÁ„o que pega os valores xi's e yi's que ser„o informados pelo usuario
		jal ler_valores_xi_yi
		#funÁ„o que pega os valores RGB que ser„o informados pelo usuario
		jal ler_valores_rgb
		#parametros retornados pela funÁ„o acima: xi, yi, xf, yf, val
		draw_full_rectangle(a1, a2, t2, t3, a3)
		
	opcao_4:
		#funÁ„o que pega os valores xi's e yi's que ser„o informados pelo usuario
		jal ler_valores_xi_yi
		#funÁ„o que pega os valores RGB que ser„o informados pelo usuario
		jal ler_valores_rgb
		#parametros retornados pela funÁ„o acima: xi, yi, xf, yf, val
		draw_empty_rectangle(a1, a2, t2, t3, a3)

	opcao_5:
		# define par√¢metros e chama a fun√ß√£o para carregar a imagem
		lw a1, address
		lw a3, size
		convert_negative()
		
	opcao_6:
		# define par√¢metros e chama a fun√ß√£o para carregar a imagem
		lw a1, address
		lw a3, size
		convert_readtones()
	
	opcao_7:
		# define par√¢metros e chama a fun√ß√£o para carregar a imagem
		la a0, image_name
		lw a1, address
		la a2, buffer
		lw a3, size
		load_image(a0, a1, a2, a3)
		
	abrir_arquivo:
		# salva os par√¢metros da fun√ßao nos tempor√°rios
		mv 	t1, a1		# endereco de carga
		mv 	t2, a2		# buffer para leitura de um pixel do arquivo
	
		# chamada de sistema para abertura de arquivo
		#par√¢metros da chamada de sistema: a7=1024, a0=string com o diret√≥rio da imagem, a1 = defini√ß√£o de leitura/escrita
		li 	a7, 1024	# chamada de sistema para abertura de arquivo
		li 	a1, 0		# Abre arquivo para leitura (pode ser 0: leitura, 1: escrita)
		ecall			# Abre um arquivo (descritor do arquivo √© retornado em a0)
		mv 	s0, a0		# salva o descritor do arquivo em s0
	
		mv 	a0, s0		# descritor do arquivo 
		mv 	a1, t2		# endere√ßo do buffer 
		li 	a2, 3		# largura do buffer
		
		jr 	ra
	
	ler_valores_rgb:
		li	a7, 4		#chamada para solicitar valor de R
		la	a0, str_valor_r	
		ecall
		
		li	a7, 5		#leitura do valor inteiro de R
		ecall
		mv	t0, a0		#t0=a0 valor de R atribuido a t0
		slli	t0, t0, 16	#move 16 bits para esquerda para o formato 0x00FF0000
		
		li	a7, 4		#chamada para solicitar valor de G
		la	a0, str_valor_g
		ecall
		
		li	a7, 5		#leitura do valor inteiro de G
		ecall
		mv	t1, a0		#t1=a0 valor de G atribuido a t1
		slli	t1, t1, 8	#move 8 bits para esquerda para o formato 0x0000FF00
		
		li	a7, 4		#chamada para solicitar valor de B
		la	a0, str_valor_b
		ecall
		
		li	a7, 5		#leitura do valor inteiro de B
		ecall
		mv	a3, a0		#a3=a0 valor de B atribuido a a3
		
		li	a7, 4
		la	a0, str_enter
		ecall
		
		or 	a3, t1, a3	#ou para unir G+B no formato 0x0000FFFF
		or 	a3, t0, a3	#ou para unir R+(G+B) no formato 0x00FFFFFF
		
		jr	ra
		
	ler_valores_xi_yi:
		li	a7, 4		#chamada de sistema para imprimir string
		la	a0, str_opcao_3_4	#a0=endere√ßo da string
		ecall			#realiza a chamada de sistema
		
		li 	a7, 5		#chamada de sistema para ler xi
		ecall			#chamada de sistema
		mv 	a1, a0		#a1=xi
		
		li 	a7, 5		#chamada de sistema para ler yi
		ecall			#chamada de sistema
		mv 	a2, a0		#a2=yi
		
		li 	a7, 5		#chamada de sistema para ler xf
		ecall			#chamada de sistema
		mv 	t2, a0		#t2=xf
		
		li 	a7, 5		#chamada de sistema para ler yf
		ecall			#chamada de sistema
		mv 	t3, a0		#t3=yf
		
		jr	ra

	#zera todas as variaveis apÛs utiliz·-las
	clear:
		li	s0, 0
		li	s1, 0
		li	s2, 0
		li	s3, 0
		li	s4, 0
		li	s5, 0
		li	t0, 0
		li	t1, 0
		li	t2, 0
		li	t3, 0
		j	main
