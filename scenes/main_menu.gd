extends Control

@onready var som_botao = $SomBotao

# Grab the Play button label
@onready var label_jogar = $Botoes/TextureButton/Label 

# FIXED: Changed "Botoes" to "Opcoes" to match your new Scene Tree!
@onready var btn_musica = $Opcoes/Musica
@onready var icon_on = $Opcoes/Musica/On
@onready var icon_off = $Opcoes/Musica/Off

# Grab the new Sair button
@onready var btn_sair = $Opcoes/Sair

# Grab your background music node
@onready var musica_menu = $MusicaMenu

func _ready():
	# Ensure the "On" icon is showing when the game starts
	icon_on.show()
	icon_off.hide()
	
	# --- CONTROLLER SUPPORT ---
	# 1. Give the controller a starting point (Highlights the JOGAR button)
	$Botoes/TextureButton.grab_focus()
	
	# 2. Make the controller trigger the exact same visual effects as the mouse
	$Botoes/TextureButton.focus_entered.connect(_on_texture_button_mouse_entered)
	$Botoes/TextureButton.focus_exited.connect(_on_texture_button_mouse_exited)
	
	btn_musica.focus_entered.connect(_on_musica_mouse_entered)
	btn_musica.focus_exited.connect(_on_musica_mouse_exited)
	
	btn_sair.focus_entered.connect(_on_sair_mouse_entered)
	btn_sair.focus_exited.connect(_on_sair_mouse_exited)

# --- PLAY BUTTON ---

func _on_texture_button_pressed():
	# 1. Disable the button
	$Botoes/TextureButton.disabled = true
	
	# 2. Play the click sound
	som_botao.play()
	
	# 3. Stop the Menu Music so they don't overlap!
	musica_menu.stop()
	
	# 4. Wait for the click sound to finish
	await som_botao.finished
	
	# 5. Start the seamless endless playlist!
	Global.start_playlist()
	
	# 6. Load the first level
	get_tree().change_scene_to_file("res://scenes/level_1.tscn")

func _on_texture_button_mouse_entered():
	# Darken the text when hovered
	label_jogar.modulate = Color(0.758, 0.758, 0.758, 1.0)

func _on_texture_button_mouse_exited():
	# Return text to white when mouse leaves
	label_jogar.modulate = Color(1.0, 1.0, 1.0)

# --- MUSIC BUTTON ---

func _on_musica_pressed():
	# 1. Play the click sound immediately!
	som_botao.play()
	
	# 2. Check if the music is currently playing
	if musica_menu.playing:
		# If playing, pause it and swap to the OFF icon
		musica_menu.stream_paused = true
		icon_on.hide()
		icon_off.show()
	else:
		# If paused, resume it and swap to the ON icon
		musica_menu.stream_paused = false
		icon_on.show()
		icon_off.hide()

func _on_musica_mouse_entered():
	# Darken the whole button when hovered
	btn_musica.modulate = Color(0.758, 0.758, 0.758, 1.0)

func _on_musica_mouse_exited():
	# Return the button to normal color when mouse leaves
	btn_musica.modulate = Color(1.0, 1.0, 1.0)

# --- EXIT BUTTON ---

func _on_sair_pressed() -> void:
	# Disable the button so it can't be clicked twice
	btn_sair.disabled = true
	
	# Play the click sound
	som_botao.play()
	await som_botao.finished
	
	# This command instantly closes the game window!
	get_tree().quit()

func _on_sair_mouse_entered() -> void:
	# Darken the exit button when hovered
	btn_sair.modulate = Color(0.758, 0.758, 0.758, 1.0)

func _on_sair_mouse_exited() -> void:
	# Return to normal color
	btn_sair.modulate = Color(1.0, 1.0, 1.0)
