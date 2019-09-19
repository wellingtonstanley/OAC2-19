#-------------------------------------------------------------------------
#		Organização e Arquitetura de Computadores - Turma C 
#			Trabalho 1 - Assembly RISC-V
#
# Nome: Anne 				Matrícula: 
# Nome: Gabriel				Matrícula: 
# Nome: Wellington Stanley				Matrícula: 11/0143981

.data

	str_enter:	.string "\n"
	str_valor_r:	.string "Valor de R: "
	str_valor_g:	.string "Valor de G: "
	str_valor_b:	.string "Valor de B: "
	str_menu:   	.string "Digite a opção desejada:\n 1 - get_point\n 2 - draw_point\n 3 - draw_full_rectangle\n 4 - draw_empty_rectangle\n 5 – convert_negative\n 6 - convert_redtones\n 7 - load_image\n 8 - sair\n"	
	str_opcao_1:   	.string "Informe os valores de x e y separados por enter:\n"
	str_opcao_3_4:  .string "Informe os valores de xi, yi, xf, yf separados por enter:\n"
	
	image_name:   	.asciz "lenaeye.raw"	# nome da imagem a ser carregada
	address: 	.word   0x10040000	# endereco do bitmap display na memoria	
	buffer:		.word   0		# configuracao default do RARS
	size:		.word	4096		# numero de pixels da imagem

.text
	#-------------------------------------------------------------------------
	# Função get_point: carrega um ponto a partir de uma coordenada informada
	# pelo usuário, retornando assim os valores R, G e B em hexadecimal na
	# saída padrão.
	#
	# Parametros:
	#  $x: inteiro, coordenada do eixo vertical, ou seja, indica qual coluna
	#  $y: inteiro, coordenada do eixo horizontal, ou seja, indica qual linha
	#
	# A função recebe os dois parametros que são o par ordenado x,y que juntos
	# indicam a localização do ponto desejado. É feita uma multiplicação por
	# 4 no x e por 256 no y usando ssli. Após isso, tanto o x quanto o y são
	# adicionados ao endereço base da heap para, assim, encontrar o ponto com
	# exatidão e em seguida carregá-lo em uma word. Posteriormente, 1 byte será
	# carregado por vez: R, G e B, respectivamente, pela instrução. O R é o 
	# terceiro byte e por isso tem 2 adicionado ao endereço base da word, e para
	# sua exibição em hexadecimal há um shift para a esquerda de 16 bits. O mesmo 
	# ocorre com o G mas, por ser o segundo byte, tem 1 adicionado ao endereço 
	# base e para hexadecimal um shitf para a esquerda de 8 bits. O B já está em 
	# conformidade. Por fim, são exibidos os valores R, G e B em hexadecimal.
	.macro get_point($x, $y)
		li	t1, 63		#como o display é invertido o calculo para y's será 63-y
		sub	t1, t1, $y	#63-y = posicao da linha informada
		slli 	t0, $x, 2  	#posicao X x 4 = coordenada dada para coluna
		slli 	t1, t1, 8  	#posicao Y x 256 = coordenada dada para linha

		add 	t2, zero, t1	#calcular linha t2 = Y x 256
		add 	t2, t2, t0	#calcular coluna t2 = (X x 4) + Y x 256
		lw 	a1, address	#endereço base heap para a1
		
		add 	t2, t2, a1	#posicao do ponto xy = endereço base + t2
		
		lw 	t1, 0(t2)	#carrega o conteudo = o ponto xy na heap para t1
		mv	a0, t1		#conteúdo do ponto para a0
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
		
		#	zerando registradores temporários +- clean
		li	t0, 0
		li	t1, 0
		li	t2, 0
		
		j main
	.end_macro
	
	#-------------------------------------------------------------------------
	# Função draw_point: desenha um ponto RGB no display. O ponto é desenhado
	# a partir de uma coordenada informada pelo usuário. Além disso, a função
	# também recebe o valor inteiro RGB.
	#
	# Parametros:
	#  $x: inteiro, coordenada do eixo vertical, ou seja, indica qual coluna
	#  $y: inteiro, coordenada do eixo horizontal, ou seja, indica qual linha
	#  $val: inteiro, valor da cor em RGB que será desenhado no display
	#
	# A função recebe os três parametros que são o par ordenado x,y que juntos
	# indicam a localização de onde o ponto será inserido. É feita uma 
	# multiplicação por 4 no x e por 256 no y usando ssli. Após isso, tanto o x quanto o y são
	# adicionados ao endereço base da heap para, assim, encontrar o ponto com
	# exatidão e em seguida armazená-lo em uma word que indica o endereço da posição no display.
	# Assim, o ponto é inserido e, por fim, as variaveis utilizadas são zeradas.
	.macro draw_point($x, $y, $val)
		li	t1, 63		#como o display é invertido o calculo para y's será 63-y
		sub	t1, t1, $y	#63-y = posicao da linha informada
		slli 	t0, $x, 2  	#posicao X x 4 = coordenada dada para coluna
		slli 	t1, t1, 8  	#posicao Y x 256 = coordenada dada para linha

		add 	t2, t2, t1	#calcular linha t3 = X x 4
		add 	t2, t2, t0	#calcular coluna t3 = (X x 4) + Y x 256
		lw 	a1, address	#endereço base heap para a1
		
		add 	t2, t2, a1	#posicao xy = endereço base + t2
		sw 	$val, 0(t2)	#armazena o conteudo RGB informado no ponto xy do display
		
		#	zerando registradores temporários +- clean
		li	t0, 0
		li	t1, 0
		li	t2, 0
		
		j	main
	.end_macro
	
	#-------------------------------------------------------------------------
	# Função draw_full_rectangle: desenha um retangulo com preenchimento no display.
	# O retangulo é desenhado a partir de coordenadas informadas pelo usuário.
	# Além disso, a função também recebe o valor inteiro RGB que será a cor do 
	# preenchimento do retangulo.
	#
	# Parametros:
	#  $xi: inteiro, coordenada do eixo vertical 1, ou seja, indica a coluna mais a direita
	#  $yi: inteiro, coordenada do eixo horizontal 1, ou seja, indica a linha superior
	#  $xf: inteiro, coordenada do eixo vertical 2, ou seja, indica a coluna mais a esquerda
	#  $yf: inteiro, coordenada do eixo horizontal 2, ou seja, indica a linha inferior
	#  $val: inteiro, valor da cor RGB do retangulo que será desenhado no display
	#
	# A função recebe os 5 parametros que são o par ordenado xi,yi que juntos
	# indicam a localização do ponto superior direito e o par xf,yf que juntos indicam a 
	# localização do ponto inferior esquerdo. Os dois pares formam o perímetro do retangulo.
	# O quinto parâmetro é a cor do retangulo. É feita uma multiplicação por 4 no xi,xf e por
	# 256 no yi,yf usando ssli para que representem o tamanho de words. Após isso, tanto o x's
	# quanto o y's são adicionados ao endereço base da heap para, assim, encontrar os pontos com
	# exatidão e em seguida armazená-los, cada um, em uma word que indica o endereço da posição no display.
	# Posteriormente, é calculado o número de linhas(yf-yi) e colunas(xi-xf) a percorrer. Com esses
	# resultados calculamos o número total de iterações(linhas X colunas) e efetuamos um loop para preencher
	# o retangulo. Por fim, as variaveis utilizadas são zeradas.
	.macro draw_full_rectangle($xi, $yi, $xf, $yf, $val)
		add	s0, zero, $xi
		add	s1, zero, $yi
		add	s2, zero, $xf
		add	s3, zero, $yf
		add	s4, zero, $val
		li	s5, 63		#como o display é invertido o calculo para y's será 63-y
		
		sub	s1, s5, s1	#linha mais acima 63-yi = faz a coordenada yi ficar de acordo com o display 0 a 63
		sub	s3, s5, s3	#linha mais abaixo 63-yf = faz a coordenada yf ficar de acordo com o display 0 a 63
		
		slli 	t0, $xi, 2  	#posicao X x 4 = coordenada dada para coluna do ponto a direita
		slli 	t1, s1, 8  	#posicao Y x 256 = coordenada dada para linha superior
		slli 	t2, $xf, 2  	#posicao X x 4 = coordenada dada para coluna do ponto a esquerda
		slli 	t3, s3, 8  	#posicao Y x 256 = coordenada dada para linha inferior

		add 	t0, t0, t1	##calcular ponto direito superior t0 = (xi x 4) + yi x 256
		add 	t1, t2, t3	#calcular ponto esquerdo inferior t1 = (xf x 4) + yf x 256
		lw 	a1, address	#endereço base heap para a1
		
		add 	t0, t0, a1	#posicao xiyi = endereço base + t0
		
		sub	a2, s0, s2	#número de colunas que serão preenchidas
		sub	a3, s3, s1	#número de linhas que serão preenchidas
		addi	a2, a2, 1	#o total de colunas vai de 0 a X+1
		addi 	a3, a3, 1	#o total de linhas vai de 0 a Y+1
		
		mul  	t1, a2,	a3	#número de iterações para preenchimento Xi colunas x Yi linhas 
		mv	t2, t0		#copia o endereço do ponto superior direito para t2
		li	t3, 0
		
		# Loop que desenha todo o retangulo no display
		# Continuará a preencher do ponto superior a direita até o ponto inferior a esquerda
		# até que todas as iterações(número de linhas x colunas = t1) acabem.
		# Desenha ponto a ponto da direita para a esquerda. A cada ponto desenhado decrementa
		# 1 no número de iterações(t1) e incrementa 1 no contador(t3) de colunas. Quando o
		# número de pontos atingir a coluna mais a esquerda da linha(a2) uma nova linha
		# abaixo será criada. O desenho dessa nova linha começará a partir da coluna mais
		# a direita(t0). Quando as iterações acabam a função clear é chamada.
		draw_full_rectangle:
			beq 	t1, zero, clear	# se todo a area foi preenchida retorna para o menu
			sw 	s4, 0(t2)	#armazena o conteudo RGB informado no ponto xy do display
			addi	t2, t2, -4	#próximo pixel a esquerda para ser preenchido
			addi	t1, t1, -1	#decrementa a quantidade de iterações= número de pontos xy
			addi	t3, t3, 1	#controla quantas colunas deve preencher por iteração
			blt	t3, a2, draw_full_rectangle #enquanto as iterações de coluna não finaliza, preencha o retangulo 
			li	t3, 0		#zera o contador de iterações para a próxima linha
			addi	t0, t0, 256	#endereço base + 256 = próxima linha
			mv	t2, t0		

			j 	draw_full_rectangle
	.end_macro
	
	#-------------------------------------------------------------------------
	# Função draw_full_rectangle: desenha um retangulo sem preenchimento no display.
	# O retangulo é desenhado a partir de coordenadas informadas pelo usuário.
	# Além disso, a função também recebe o valor inteiro RGB que será a cor do 
	# contorno do retangulo.
	#
	# Parametros:
	#  $xi: inteiro, coordenada do eixo vertical 1, ou seja, indica a coluna mais a direita
	#  $yi: inteiro, coordenada do eixo horizontal 1, ou seja, indica a linha superior
	#  $xf: inteiro, coordenada do eixo vertical 2, ou seja, indica a coluna mais a esquerda
	#  $yf: inteiro, coordenada do eixo horizontal 2, ou seja, indica a linha inferior
	#  $val: inteiro, valor da cor RGB do retangulo que será desenhado no display
	#
	# A função recebe os 5 parametros que são o par ordenado xi,yi que juntos
	# indicam a localização do ponto inferior esquerdo e o par xf,yf que juntos indicam a 
	# localização do ponto superior direito. Os dois pares formam o perímetro do retangulo.
	# O quinto parâmetro é a cor da borda do retangulo. É feita uma multiplicação por 4 no xi,xf e por
	# 256 no yi,yf usando ssli para que representem o tamanho de words. Após isso, tanto o x's
	# quanto o y's são adicionados ao endereço base da heap para, assim, encontrar os pontos com
	# exatidão e em seguida armazená-los, cada um, em uma word que indica o endereço da posição no display.
	# Posteriormente, é calculado o número de linhas(yf-yi) e colunas(xi-xf) a percorrer. Com esses
	# resultados calculamos o número total de iterações(linhas=a3) para efetuarmos o loop 
	# para preencher a borda esquerda e direita; e o número de iterações(colunas=a2) para preencher
	# a linha superior e a inferior. 
	# Por fim, as variaveis utilizadas são zeradas.
	.macro draw_empty_rectangle($xi, $yi, $xf, $yf, $val)
		add	s0, zero, $xi
		add	s1, zero, $yi
		add	s2, zero, $xf
		add	s3, zero, $yf
		add	s4, zero, $val
		li	s5, 63		#como o display é invertido o calculo para y's será 63-y
		
		sub	s1, s5, s1	#linha mais abaixo 63-yi = faz a coordenada yi ficar de acordo com o display 0 a 63
		sub	s3, s5, s3	#linha mais abaixo 63-yf = faz a coordenada yf ficar de acordo com o display 0 a 63
		
		slli 	t0, $xi, 2  	#posicao X x 4 = coordenada dada para coluna do ponto a esquerda
		slli 	t1, s1, 8  	#posicao Y x 256 = coordenada dada para linha inferior
		slli 	t2, $xf, 2  	#posicao X x 4 = coordenada dada para coluna do ponto a direita
		slli 	t3, s3, 8  	#posicao Y x 256 = coordenada dada para linha superior

		add 	t0, t0, t1	#calcular coluna t0 = (xi x 4) + yi x 256
		add 	t1, t2, t3	#calcular coluna t1 = (xf x 4) + yf x 256
		lw 	a1, address	#endereço base heap para a1
		
		add 	t0, t0, a1	#posicao xiyi = endereço base + t0
		add 	t2, t1, a1	#posicao xfyf = endereço base + t1
		
		sub	a2, s2, s0	#número de colunas que serão preenchidas
		sub	a3, s1, s3	#número de linhas que serão preenchidas
		slli	s1, a2, 2	#numero de colunas x 4 bytes representará cada ponto vertical esquerdo
		addi	a2, a2, 1	#o total de colunas vai de 0 a X+1
		addi 	a3, a3, 1	#o total de linhas vai de 0 a Y+1
		
		mv  	t1, a3		#número de iterações para preenchimento de Y linhas 
		mv	t0, t2		#copia o endereço do ponto superior direito para t2
		mv	t3, a2
		li	s0, 1
		
		# Loop que desenha todo o retangulo sem preenchimento no display.
		# Continuará a preencher o ponto mais a direita e o ponto mais a esquerda de cada
		# linnha, exceto a primeira e última, até que todas as iterações(número de linhas = t1) acabem.
		# Desenha um ponto mais a direita, um mais a esquerda na mesma linha, decrementa 1 no número 
		# de iterações(t1) e vai para a próxima linha(t0+256).
		# Se for a primeira ou última linha uma função para preencher a linha é acionada=draw_full_line.
		draw_empty_rectangle:
			beq 	t1, zero, clear	# se toda o contorno for preenchido retorna para o menu
			beq	t1, a3, draw_full_line #se esta na primeira linha t1=a3, preenche toda linha
			sw 	s4, 0(t2)	#armazena o conteudo RGB informado no ponto xy da borda mais a direita
			sub	t2, t2, s1	#próximo pixel a esquerda para ser preenchido
			sw	s4, 0(t2)	#armazena o conteudo RGB informado no ponto xy da borda mais esquerda 
			addi	t1, t1, -1	#decrementa a quantidade de iterações= número de linhas
			addi	t0, t0, 256	#endereço base + 256 = próxima linha
			mv	t2, t0		#t2=t0
			beq	t1, s0, draw_full_line #se esta na ultima linha t1=s0, preenche toda linha
					
			j	draw_empty_rectangle

		# Preenche toda a linha, ou seja, superior ou inferior.
		# Continuará a preencher do ponto mais a direita até o ponto mais a esquerda
		# da linha que todas as iterações(número de linhas = t1) acabem.
		# Desenha ponto a ponto da direita para a esquerda. A cada ponto desenhado decrementa
		# 1 no contador(t3) de colunas. Quando o número de pontos atingir a coluna mais a esquerda
		# da linha(t3=0) decrementa o número de iterações totais(t1), vai para a próxima linha(t0+256) 
		# e retorna para a função que preenche os pontos a esquerda e direita= draw_empty_rectangle.

		draw_full_line:
			sw 	s4, 0(t2)	#armazena o conteudo RGB informado no ponto xy do display
			addi	t2, t2, -4	#próximo pixel a esquerda para ser preenchido
			addi	t3, t3, -1	#decrementa a quantidade de iterações= número de colunas
			bgt 	t3, zero, draw_full_line # se todo a area foi preenchida retorna para o menu
			mv	t3, a2		#t3= total de colunas para preencher outra linha em outro loop
			addi	t1, t1, -1	#decrementa a quantidade de iterações= número linhas
			addi	t0, t0, 256	#t0 = endereço base + 256 = próxima linha
			mv	t2, t0		#t2= t0
			j	draw_empty_rectangle
			
	.end_macro
	
	#FunÃ§Ã£o que inverte as cores da imagem atravÃ©s da subtraÃ§Ã£o entre o valor 255 e os componentes RGB, retornando o negativo da mesma 
	.macro convert_negative()
		mv 	t1, a1	#t1=a1 copiar base da heap para t1
		convert_negative:
			beq 	a3, zero, close		#verifica se o contador de pixels da imagem chegou a 0
			lw	 t0, 0(t1)   		# lÃª pixel do display
			li	 t2, 255 		#Atribui o valor 255 ao t2 
			sub	 t0, t2, t0 		#t0 = t2 - t0 --> t0 = 255(que ï¿½ transformado pra hexa pelo rars) - (hexadecimal do pixel atual)
			sw	 t0, 0(t1)   		# escreve pixel no display
			addi	 t1, t1, 4  		# prÃ³ximo pixel
			addi	 a3, a3, -1  		# decrementa countador de pixels da imagem
		
			j convert_negative
	.end_macro
	
	.macro convert_readtones()
		mv 	t1, a1	#t1=a1 copiar base da heap para t1
		
		#funÃ§Ã£o que converte para zero os componentes G e B do ponto, mantendo somente ativo o componente R
		convert_redtones:
			beq a3, zero, close		#verifica se o contador de pixels da imagem chegou a 0
			lw   t0, 0(t1)   		# lÃª pixel do display
			li t2, 0x00ff0000		#Atribui o hexadecimal da cor vermelha ao t2
			and t0, t2, t0 			#Faz um and bit a bit com o intuito de zerar todos os bits, menos os bits correspondentes a cor vermelha
			sw   t0, 0(t1)   		# escreve pixel no display
			addi t1, t1, 4  		# prÃ³ximo pixel
			addi a3, a3, -1  		# decrementa countador de pixels da imagem
		
			j convert_redtones
	.end_macro
	
	.macro load_image($image_name, $address, $buffer, $size)
		# salva os parÃ¢metros da funÃ§ao nos temporÃ¡rios
		mv 	t0, $image_name	# nome do arquivo
		mv 	t1, $address	# endereco de carga
		mv 	t2, $buffer	# buffer para leitura de um pixel do arquivo
	
		# chamada de sistema para abertura de arquivo
		#parÃ¢metros da chamada de sistema: a7=1024, a0=string com o diretÃ³rio da imagem, a1 = definiÃ§Ã£o de leitura/escrita
		li 	a7, 1024	# chamada de sistema para abertura de arquivo
		li 	a1, 0		# Abre arquivo para leitura (pode ser 0: leitura, 1: escrita)
		ecall			# Abre um arquivo (descritor do arquivo Ã© retornado em a0)
		mv 	s0, a0		# salva o descritor do arquivo em s0
	
		mv 	a0, s0		# descritor do arquivo 
		mv 	a1, t2		# endereÃ§o do buffer 
		li 	a2, 3		# largura do buffer

		#loop utilizado para ler pixel a pixel da imagem
		loop:  
		
			beq  	$size, zero, close	#verifica se o contador de pixels da imagem chegou a 0

			#chamada de sistema para leitura de arquivo
			#parÃ¢metros da chamada de sistema: a7=63, a0=descritor do arquivo, a1 = endereÃ§o do buffer, a3 = mÃ¡ximo tamanho pra ler
			li	a7, 63		# definiÃ§Ã£o da chamada de sistema para leitura de arquivo 
			ecall            	# lÃª o arquivo
			lw	t3, 0(a1)	# lÃª pixel do buffer	
			sw	t3, 0(t1)   	# escreve pixel no display
			addi 	t1, t1, 4  	# prÃ³ximo pixel
			addi 	$size, $size, -1  	# decrementa countador de pixels da imagem
		
			j loop
	.end_macro
	
	# Função que exibe o menu de opções e direciona para a opção escolhida.
	# O intuito é permanecer no menu até o usuario digitar a opção 8	
	main:
		jal exibe_menu
	
		li 	a7, 5		#a7=5 -> definiÃ§Ã£o da chamada de sistema para ler opcao do usuario
		ecall			#realiza a chamada de sistema
		mv 	t0, a0
		
		#de acordo com a opcao informada pelo usuario alguma opcao será acionada	
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
		#definiÃ§Ã£o da chamada de sistema para encerrar programa	
		#parÃ¢metros da chamada de sistema: a7=10
		li a7, 10		
		ecall

	
	# Fecha o arquivo após a utilização.
	close:
		# chamada de sistema para fechamento do arquivo
		#parÃ¢metros da chamada de sistema: a7=57, a0=descritor do arquivo
		li	a7, 57		# chamada de sistema para fechamento do arquivo
		mv 	a0, s0		# descritor do arquivo a ser fechado
		ecall		        # fecha arquivo
		#	zerando registradores temporários +- clean
		li	t0, 0
		li	t1, 0
		li	t2, 0
		#retorna para o menu	
		j 	main
		
	# Label responsável por exibir as opções do menu e retornar para main.
	exibe_menu:
		li	a7, 4		#a7=4 -> definiÃ§Ã£o da chamada de sistema para imprimir strings na tela
		la	a0, str_menu	#a0=endereÃ§o da string "str_menu"
		ecall			#realiza a chamada de sistema
		jr 	ra

	# Label responsável por obter os dados e passar para a função get_point.
	opcao_1:
		li	a7, 4		#chamada de sistema para imprimir string
		la	a0, str_opcao_1	#a0=endereÃ§o da string
		ecall			#realiza a chamada de sistema
		
		li 	a7, 5		#chamada de sistema para ler x
		ecall			#chamada de sistema
		mv 	t0, a0		#t0=x
		
		li 	a7, 5		#chamada de sistema para ler y
		ecall			#chamada de sistema
		mv 	t1, a0		#t1=y
				
		get_point(t0, t1)
	
	# Label responsável por obter os dados e passar para a função draw_point.
	opcao_2:
		li	a7, 4		#chamada de sistema para imprimir string
		la	a0, str_opcao_1	#a0=endereÃ§o da string
		ecall			#realiza a chamada de sistema
		
		li 	a7, 5		#chamada de sistema para ler x
		ecall			#chamada de sistema
		mv 	a1, a0		#a1=x
		
		li 	a7, 5		#chamada de sistema para ler y
		ecall			#chamada de sistema
		mv 	a2, a0		#a2=y
		
		jal ler_valores_rgb

		draw_point(a1, a2, a3)
	
	# Label responsável por obter os dados através de funções auxiliares e passar para a 
	# função draw_full_rectangle	
	opcao_3:
		#função que pega os valores xi's e yi's que serão informados pelo usuario
		jal ler_valores_xi_yi
		#função que pega os valores RGB que serão informados pelo usuario
		jal ler_valores_rgb
		#parametros retornados pela função acima: xi, yi, xf, yf, val
		draw_full_rectangle(a1, a2, t2, t3, a3)
	
	# Label responsável por obter os dados através de funções auxiliares e passar para a 
	# função draw_empty_rectangle
	opcao_4:
		#função que pega os valores xi's e yi's que serão informados pelo usuario
		jal ler_valores_xi_yi
		#função que pega os valores RGB que serão informados pelo usuario
		jal ler_valores_rgb
		#parametros retornados pela função acima: xi, yi, xf, yf, val
		draw_empty_rectangle(a1, a2, t2, t3, a3)

	# Label responsável por carregar parametros e chamar a função convert_negative.
	opcao_5:
		# define parÃ¢metros e chama a funÃ§Ã£o para carregar a imagem
		lw a1, address
		lw a3, size
		convert_negative()
	
	# Label responsável por carregar parametros e chamar a função convert_readtones
	opcao_6:
		# define parÃ¢metros e chama a funÃ§Ã£o para carregar a imagem
		lw a1, address
		lw a3, size
		convert_readtones()
	
	# Label responsável por carregar parametros e chamar a função load_image
	opcao_7:
		# define parÃ¢metros e chama a funÃ§Ã£o para carregar a imagem
		la a0, image_name
		lw a1, address
		la a2, buffer
		lw a3, size
		load_image(a0, a1, a2, a3)

	# Tem a atribuição de ler os valores inteiros R, G e B e
	# preparar um valor RGB em hexadecimal. Os passos são:
	# 1 - ler o valor R e armazenar em uma word de 32 bits
	#     mover 16 bits a esquerda e deixar no formato RGB
	# 2 - ler o valor G e armazenar em uma word de 32 bits
	#     mover 8 bits a esquerda e deixar no formato RGB
	# 3 - ler o valor B e armazenar em uma word de 32 bits
	# 4 - efetuar um R or B or C para obter o RGB completo
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
	
	# Tem a atribuição de obter os dados xi, yi, xf, yf e armazenar em variáveis
	# para que funções que chamam esse label possam utilizá-las. Os dados obtidos
	# por este rótulo fornecem as coordenadas de pontos iniciais e finais no
	# display.
	ler_valores_xi_yi:
		li	a7, 4		#chamada de sistema para imprimir string
		la	a0, str_opcao_3_4	#a0=endereÃ§o da string
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

	# Zera todas as variaveis após utilizá-las e retorna para a main
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
