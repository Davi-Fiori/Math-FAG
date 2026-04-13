extends Control

@onready var som_botao = $SomBotao

# Grab the Label directly instead of the old container
@onready var label_jogar = $TextureButton/Label 

# ... (Keep your existing pressed function) ...

func _on_texture_button_mouse_entered():
	# Darken the text
	label_jogar.modulate = Color(0.6, 0.6, 0.6)

func _on_texture_button_mouse_exited():
	# Return text to white
	label_jogar.modulate = Color(1.0, 1.0, 1.0)
