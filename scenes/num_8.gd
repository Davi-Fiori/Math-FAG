extends Area2D

@export var value: int = 8 

func _ready():
	# Adiciona automaticamente este número a um grupo chamado "numbers"
	add_to_group("numbers")

func _on_body_entered(body):
	if body.name == "caranguejo":
		# Avisa a fase principal qual foi o valor coletado
		get_tree().current_scene.check_answer(value)
		
		# Destrói o número da tela imediatamente para não causar colisão dupla!
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	pass # Pode deixar isso aqui caso precise usar no futuro
