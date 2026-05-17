extends Area2D

func _on_body_entered(body):
	# Check if the thing that touched the spike is your crab!
	if body.name == "caranguejo":
		
		# Since the crab has a built-in death function, we just call it!
		body.die()
