extends Area2D

@export var value: int = 11

func _ready():
	# This automatically adds every number to a group called "numbers"
	add_to_group("numbers")

func _on_body_entered(body):
	if body.name == "caranguejo":
		get_tree().current_scene.check_answer(value)
		
		# --- FIXED: Delete this specific number immediately! ---
		queue_free()
