extends Control

# Grab the nodes using the exact paths from your Scene Tree
@onready var grid = $TextureRect/GridContainer
@onready var som_botao = $SomBotao

func _ready():
	# 1. Always make sure we have the latest save data loaded
	Global.load_game()
	
	# 2. Get a list of all 7 buttons inside the GridContainer
	# (Godot grabs them in the exact top-to-bottom order you see in the Scene Tree!)
	var botoes = grid.get_children()
	
	# 3. Loop through every button
	for i in range(botoes.size()):
		var btn = botoes[i] as TextureButton
		
		# The first button in the list (index 0) is Level 1, so we add 1
		var level_num = i + 1 
		
		# 4. Check if the level is locked
		if level_num > Global.levels_unlocked:
			# Disable clicking and darken the button using 'modulate'
			btn.disabled = true
			btn.modulate = Color(0.3, 0.3, 0.3, 1.0) 
		else:
			# Unlock the button and ensure normal color
			btn.disabled = false
			btn.modulate = Color(1.0, 1.0, 1.0, 1.0)
			
			# Connect the button click to our function below, passing the level number!
			if not btn.pressed.is_connected(_on_level_btn_pressed):
				btn.pressed.connect(_on_level_btn_pressed.bind(level_num))

func _on_level_btn_pressed(level_num: int):
	# Optional safety feature: Disable all buttons instantly so the 
	# player can't double-click and crash the game while loading!
	for btn in grid.get_children():
		if btn is TextureButton:
			btn.disabled = true
			
	# Play the click sound
	som_botao.play()
	await som_botao.finished
	
	# Dynamically build the path to the level and load it
	var level_path = "res://scenes/level_" + str(level_num) + ".tscn"
	get_tree().change_scene_to_file(level_path)
