extends Area2D

func _on_body_entered(body):
	if body.name == "caranguejo":
		
		# 1. Save the score from the timer (from our previous setup!)
		var time_left = get_tree().current_scene.timer.time_left
		Global.total_score += int(time_left) * 10
		print("Current Score: ", Global.total_score)
		
		# 2. Figure out what level file we are currently in (e.g., "res://scenes/level_1.tscn")
		var current_path = get_tree().current_scene.scene_file_path 
		
		# This extracts just the "1" and turns it into math text
		var level_number = current_path.get_file().get_basename().trim_prefix("level_").to_int()
		
		# 3. Add 1 to find the next level
		var next_level_number = level_number + 1
		var next_level_path = "res://scenes/level_" + str(next_level_number) + ".tscn"
		
		# 4. Check if that next level actually exists in your files!
		if ResourceLoader.exists(next_level_path):
			get_tree().change_scene_to_file(next_level_path)
		else:
			print("YOU BEAT THE GAME!")
			# Eventually you can load a "res://scenes/victory_screen.tscn" here!
