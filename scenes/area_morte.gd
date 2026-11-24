extends Area2D

func _ready() -> void:
	# Automatically connect the signal via code so you don't have to wire it manually in every level
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("die"):
			body.die()
