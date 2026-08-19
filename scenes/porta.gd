extends Area2D

# The Level script will call this function and pass the remaining time!
func advance_level(time_left):
	# SISTEMA SCORE, IMPLEMENTAR NA HUD DEPOIS
	Global.total_score += int(time_left) * 10

	# 2. Smart Door Math
	var current_path = get_tree().current_scene.scene_file_path 
	var level_number = current_path.get_file().get_basename().trim_prefix("level_").to_int()
	var next_level_number = level_number + 1
	
	# --- THE FIREBASE & UNLOCK FIX ---
	# Check if this is a brand new level they just unlocked
	if next_level_number > Global.levels_unlocked:
		Global.levels_unlocked = next_level_number
		
		# Save to the browser so they don't lose progress if they close the tab
		Global.save_game()
		
		# Send the updated "Fase" number directly to your Supabase/Firebase dashboard!
		Global.sync_to_cloud()
	# ---------------------------------
	
	var next_level_path = "res://scenes/level_" + str(next_level_number) + ".tscn"
	
	# 3. Safe level transition using call_deferred!
	if ResourceLoader.exists(next_level_path):
		get_tree().call_deferred("change_scene_to_file", next_level_path)
	else:
		print("YOU BEAT THE GAME!")
		# I highly recommend sending them back to your new Level Select screen here!
		get_tree().call_deferred("change_scene_to_file", "res://scenes/level_select.tscn")
