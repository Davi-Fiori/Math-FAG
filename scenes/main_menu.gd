extends Control

@onready var som_botao = $SomBotao

# Added "Botoes/" so Godot looks inside the container first
@onready var label_jogar = $Botoes/TextureButton/Label 

func _on_texture_button_pressed():
	# 1. Disable the button (Added "Botoes/" here too!)
	$Botoes/TextureButton.disabled = true
	
	# 2. Play the click sound
	som_botao.play()
	
	# 3. Wait for the sound to completely finish playing
	await som_botao.finished
	
	# 4. Load the first level!
	get_tree().change_scene_to_file("res://scenes/level_1.tscn")

# --- Hover Effects ---

func _on_texture_button_mouse_entered():
	# Darken the text when hovered
	label_jogar.modulate = Color(0.758, 0.758, 0.758, 1.0)

func _on_texture_button_mouse_exited():
	# Return text to white when mouse leaves
	label_jogar.modulate = Color(1.0, 1.0, 1.0)


func _on_texture_button_2_mouse_entered() -> void:
	pass # Replace with function body.


func _on_texture_button_2_mouse_exited() -> void:
	pass # Replace with function body.
