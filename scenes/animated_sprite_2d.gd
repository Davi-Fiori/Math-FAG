extends Node2D

@export var velocidade: float = 45.0 
# Distância que ele navega para a esquerda até sair totalmente da tela
@export var distancia_sumir_direita: float = 300.0 
# Distância extra para trás (direita) onde ele vai "nascer" de novo
@export var recuo_nascer_esquerda: float = 200.0 

var posicao_inicial_x: float

func _ready():
	# Salva a posição em que você colocou ele no editor
	posicao_inicial_x = position.x

func _process(delta):
	# 1. Mudamos de += para -= para o barco andar para a ESQUERDA
	position.x -= velocidade * delta
	
	# 2. Invertemos o sinal para <= e subtraímos a distância para checar o limite esquerdo
	if position.x <= posicao_inicial_x - distancia_sumir_direita:
		# 3. Somamos o recuo para ele "nascer" lá atrás do lado DIREITO
		position.x = posicao_inicial_x + recuo_nascer_esquerda
