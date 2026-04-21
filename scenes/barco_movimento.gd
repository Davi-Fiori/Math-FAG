extends Node2D

@export var velocidade: float = 20.0 
# Distância que ele navega para a direita até sair totalmente da tela
@export var distancia_sumir_direita: float = 300.0 
# Distância extra para trás (esquerda) onde ele vai "nascer" de novo
@export var recuo_nascer_esquerda: float = 200.0 

var posicao_inicial_x: float

func _ready():
	# Salva a posição em que você colocou ele no editor
	posicao_inicial_x = position.x

func _process(delta):
	position.x += velocidade * delta
	
	# Se o barco passar do limite estipulado na direita...
	if position.x >= posicao_inicial_x + distancia_sumir_direita:
		# ...ele não volta para o ponto inicial. Ele volta para MAIS atrás (subtraindo)!
		position.x = posicao_inicial_x - recuo_nascer_esquerda
