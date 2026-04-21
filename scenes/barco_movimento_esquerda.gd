extends StaticBody2D

# Velocidade do barco em pixels por segundo
@export var velocidade: float = 33.0

# Ponto de partida (X) e ponto de chegada (X)
var limite_esquerda: float = -190.0 # Onde ele "some"
var limite_direita: float = 300.0 # Onde ele "renasce"

func _process(delta):
	# Move o barco para a esquerda
	position.x -= velocidade * delta
	
	# Verifica se o barco saiu totalmente da visão à esquerda
	if position.x < limite_esquerda:
		# Reposiciona o barco para a direita, fora da tela
		position.x = limite_direita
