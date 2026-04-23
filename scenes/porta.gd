extends Area2D

# The Level script will call this function and pass the remaining time!
func advance_level(time_left):
	# SISTEMA SCORE, IMPLEMENTAR NA HUD DEPOIS
	Global.total_score += int(time_left) * 10

	# 2. Smart Door Math
	var current_path = get_tree().current_scene.scene_file_path 
	var level_number = current_path.get_file().get_basename().trim_prefix("level_").to_int()
	var next_level_number = level_number + 1
	var next_level_path = "res://scenes/level_" + str(next_level_number) + ".tscn"
	
	# 3. Safe level transition using call_deferred!
	if ResourceLoader.exists(next_level_path):
		get_tree().call_deferred("change_scene_to_file", next_level_path)
	else:
		print("YOU BEAT THE GAME!")
		get_tree().call_deferred("change_scene_to_file", "res://scenes/level_5.tscn")
