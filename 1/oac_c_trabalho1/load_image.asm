#-------------------------------------------------------------------------
#		Organização e Arquitetura de Computadores - Turma C 
#			Trabalho 1 - Assembly RISC-V
#
# Nome: Anne 				Matrícula: 
# Nome: Gabriel				Matrícula: 
# Nome: Wellington Stanley				Matrícula: 11/0143981

.data
	str_menu:   	.string "Digite a op��o desejada:\n 1 - get_point\n 2 - draw_point\n 3 - draw_full_rectangle\n 4 - draw_empty_rectangle\n 5 � convert_negative\n 6 - convert_redtones\n 0 - sair\n"	
	str_opcao_1:   	.string "Informe os valores de x e y:\n"
	#vetor:		.word 0, 1, 2, 3, 4, 5, 6
	tab:		.string "\n"
	
	image_name:   	.asciz "lenaeye.raw"	# nome da imagem a ser carregada
	address: 	.word   0x10040000			# endereco do bitmap display na memoria	
	buffer:		.word   0					# configuracao default do RARS
	size:		.word	4096				# numero de pixels da imagem

.text

	.macro get_point($x, $y)
		#chamada de sistema para imprimir strings na tela -> definida por a7=4 
		#parâmetros: a0 -> endereço da string que se quer imprimir
		#retorno: imprime uma string no console
		li	a7, 1		#imprimir x
		add 	a0, x0, $x 	#a0=endereço do inteiro
		ecall			#chamada de sistema
		
		li	a7, 4
		la	a0, tab
		ecall
		
		li	a7, 1	#imprimir x
		add	a0, x0, $y	#a0=endereço do inteiro
		ecall		#chamada de sistema
		
		
	.end_macro

	# define parâmetros e chama a função para carregar a imagem
	la a0, image_name
	lw a1, address
	la a2, buffer
	lw a3, size
	jal load_image
	
	main:	# o intuito � permanecer no menu at� o usuario digitar a op��o 0
		jal exibe_menu
	
		li a7, 5		#a7=5 -> definição da chamada de sistema para ler opcao do usuario
		ecall			#realiza a chamada de sistema
		mv t0, a0
			
		li t1, 1
		beq t0, t1, opcao_1
  	
	#definição da chamada de sistema para encerrar programa	
	#parâmetros da chamada de sistema: a7=10
	li a7, 10		
	ecall

	#-------------------------------------------------------------------------
	# Funcao load_image: carrega uma imagem em formato RAW RGB para memoria
	# Formato RAW: sequencia de pixels no formato RGB, 8 bits por componente
	# de cor, R o byte mais significativo
	#
	# Parametros:
	#  a0: endereco do string ".asciz" com o nome do arquivo com a imagem
	#  a1: endereco de memoria para onde a imagem sera carregada
	#  a2: endereco de uma palavra na memoria para utilizar como buffer
	#  a3: tamanho da imagem em pixels
	#
	# A função foi implementada ... (explicação da função)
  
	load_image:
		# salva os parâmetros da funçao nos temporários
		mv t0, a0		# nome do arquivo
		mv t1, a1		# endereco de carga
		mv t2, a2		# buffer para leitura de um pixel do arquivo
	
		# chamada de sistema para abertura de arquivo
		#parâmetros da chamada de sistema: a7=1024, a0=string com o diretório da imagem, a1 = definição de leitura/escrita
		li a7, 1024		# chamada de sistema para abertura de arquivo
		li a1, 0		# Abre arquivo para leitura (pode ser 0: leitura, 1: escrita)
		ecall			# Abre um arquivo (descritor do arquivo é retornado em a0)
		mv s6, a0		# salva o descritor do arquivo em s6
	
		mv a0, s6		# descritor do arquivo 
		mv a1, t2		# endereço do buffer 
		li a2, 3		# largura do buffer
	
	#loop utilizado para ler pixel a pixel da imagem
	loop:  
		
		beq a3, zero, close		#verifica se o contador de pixels da imagem chegou a 0
		
		#chamada de sistema para leitura de arquivo
		#parâmetros da chamada de sistema: a7=63, a0=descritor do arquivo, a1 = endereço do buffer, a2 = máximo tamanho pra ler
		li a7, 63				# definição da chamada de sistema para leitura de arquivo 
		ecall            		# lê o arquivo
		lw   t4, 0(a1)   		# lê pixel do buffer	
		sw   t4, 0(t1)   		# escreve pixel no display
		addi t1, t1, 4  		# próximo pixel
		addi a3, a3, -1  		# decrementa countador de pixels da imagem
		
		j loop
	
	exibe_menu:
		li	a7, 4		#a7=4 -> definição da chamada de sistema para imprimir strings na tela
		la	a0, str_menu	#a0=endereço da string "str"
		ecall			#realiza a chamada de sistema
		jr ra
		
	opcao_1:
		li	a7, 4		#chamada de sistema para imprimir string
		la	a0, str_opcao_1	#a0=endereço da string
		ecall			#realiza a chamada de sistema
		
		li 	a7, 5		#chamada de sistema para ler x
		ecall			#chamada de sistema
		mv 	t0, a0		#t0=x
		
		li 	a7, 5		#chamada de sistema para ler y
		ecall			#chamada de sistema
		mv 	t1, a0		#t0=y
				
		get_point(t0, t1)
		
		
	
		# fecha o arquivo 
	close:
		# chamada de sistema para fechamento do arquivo
		#parâmetros da chamada de sistema: a7=57, a0=descritor do arquivo
		li a7, 57		# chamada de sistema para fechamento do arquivo
		mv a0, s6		# descritor do arquivo a ser fechado
		ecall           # fecha arquivo
			
		jr ra
	
  
  
