extends Control

# Grab your button node for the hover effects 
# (Make sure this path perfectly matches your Scene Tree!)
@onready var btn_voltar = $Botoes/Voltar

func _ready() -> void:
	$Botoes/Voltar.grab_focus()
	# Optional: If you want the level music to stop exactly when this screen loads
	# Global.stop_playlist()
	pass

func _on_voltar_pressed() -> void:
	# 1. Disable the button so it can't be spammed
	btn_voltar.disabled = true
	
	# 2. Reset the score so the next playthrough starts fresh!
	Global.total_score = 0
	
	# 3. Stop the global level music (so it doesn't overlap the main menu music)
	Global.stop_playlist()
	
	# 4. Load the Main Menu
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

# --- HOVER EFFECTS ---

func _on_voltar_mouse_entered() -> void:
	# Darken the button when hovered
	btn_voltar.modulate = Color(0.758, 0.758, 0.758, 1.0)

func _on_voltar_mouse_exited() -> void:
	# Return to normal color
	btn_voltar.modulate = Color(1.0, 1.0, 1.0)
