extends Area2D

func _on_body_entered(body):
	if body.name == "caranguejo":
		print("Level Complete! Moving to Level 2...")
		# get_tree().change_scene_to_file("res://scenes/level_2.tscn")
