extends Area2D

func advance_level(time_left):
	# Prevent the door from triggering twice during the fade animation!
	if SceneManager.is_transitioning:
		return

	Global.total_score += int(time_left) * 10
	
	var current_path = get_tree().current_scene.scene_file_path 
	var level_number = current_path.get_file().get_basename().trim_prefix("level_").to_int()
	var next_level_number = level_number + 1
	
	if next_level_number > Global.levels_unlocked:
		Global.levels_unlocked = next_level_number
		Global.save_game()
		Global.sync_to_cloud()
		
	var next_level_path = "res://scenes/level_" + str(next_level_number) + ".tscn"
	
	if ResourceLoader.exists(next_level_path):
		SceneManager.change_scene.call_deferred(next_level_path, {
			"pattern": "circle",
			"speed": 2.5,
			"wait_time": 0.15
		})
	else:
		SceneManager.change_scene.call_deferred("res://scenes/level_select.tscn", {
			"pattern": "fade",
			"speed": 2.0
		})
