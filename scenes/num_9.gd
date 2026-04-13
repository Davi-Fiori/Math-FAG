extends Area2D

@export var value: int = 9

func _ready():
	# This automatically adds every number to a group called "numbers"
	add_to_group("numbers")

func _on_body_entered(body):
	if body.name == "caranguejo": # (or whatever your crab's exact name is!)
		# Tells the level what number was grabbed
		get_tree().current_scene.check_answer(value)
		
		# Deletes this specific number from the screen instantly
		queue_free()
