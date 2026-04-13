extends Area2D

@export var value: int = 2 

func _ready():
	# This automatically adds every number to a group called "numbers"
	add_to_group("numbers")

func _on_body_entered(body):
	if body.name == "caranguejo":
		get_tree().current_scene.check_answer(value)
		# Note: You can actually remove queue_free() from here now, 
		# because the group command in Step 2 will delete this one too!
