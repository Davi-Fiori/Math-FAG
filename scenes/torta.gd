extends Area2D

func _on_body_entered(body):
	# Check if the thing that touched the spike is your crab
	if body.name == "caranguejo":
		
		# Check if another spike ALREADY marked the crab as dead this exact frame
		if not body.has_meta("is_dead"):
			
			# Instantly slap the invisible "dead" sticker on the crab
			body.set_meta("is_dead", true)
			
			# 1. Figure out what level we are currently on
			var current_path = get_tree().current_scene.scene_file_path
			var level_number = current_path.get_file().get_basename().trim_prefix("level_").to_int()
			
			# 2. Tell Global to log exactly ONE obstacle death!
			Global.log_error(level_number, "obstaculos")
			
			# 3. Call the crab's built-in death function
			body.die()
