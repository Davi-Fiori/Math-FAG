extends Control

@onready var som_botao = $SomBotao

# Grab the Play button label
@onready var label_jogar = $Botoes/TextureButton/Label 

# Grab Options buttons
@onready var btn_musica = $Opcoes/Musica
@onready var icon_on = $Opcoes/Musica/On
@onready var icon_off = $Opcoes/Musica/Off
@onready var btn_sair = $Opcoes/Sair

# Grab your background music node
@onready var musica_menu = $MusicaMenu

# --- AGE POP-UP VARIABLES ---
@onready var age_popup = $AgePopup
@onready var name_input = $AgePopup/TexturaPopUp/NameEdit
@onready var age_dropdown = $AgePopup/TexturaPopUp/AgeDropdown
@onready var confirm_button = $AgePopup/TexturaPopUp/TextureButton

func _ready():
	# Ensure the "On" icon is showing when the game starts
	icon_on.show()
	icon_off.hide()
	
	# --- CHECK IF AGE WAS ALREADY ENTERED BEFORE ---
	Global.load_game()
	if Global.player_age > 0:
		# Browser already has an ID and Age! Skip pop-up entirely.
		age_popup.hide() 
		$Botoes/TextureButton.grab_focus()
	else:
		# First time visitor on this browser instance! Show the pop-up.
		age_popup.show()
		confirm_button.pressed.connect(_on_confirm_button_pressed)
		
		# 1. Add a placeholder text at the very top (Index 0)
		age_dropdown.add_item("Idade")
		age_dropdown.set_item_disabled(0, true) # Prevents selecting the word "Idade"
		
		# 2. Automatically generate numbers 1 through 99
		for i in range(1, 100):
			age_dropdown.add_item(str(i))
			
		# 3. FORCE IT TO DISPLAY "Idade" BY DEFAULT!
		age_dropdown.select(0) # <-- ADDED: This fixes the blank dropdown bug!
		age_dropdown.text = "Idade"
			
		# Give the controller focus to the Name box first
		name_input.grab_focus()
		
	
	# --- CONTROLLER SUPPORT (Visuals) ---
	$Botoes/TextureButton.focus_entered.connect(_on_texture_button_mouse_entered)
	$Botoes/TextureButton.focus_exited.connect(_on_texture_button_mouse_exited)
	
	btn_musica.focus_entered.connect(_on_musica_mouse_entered)
	btn_musica.focus_exited.connect(_on_musica_mouse_exited)
	
	btn_sair.focus_entered.connect(_on_sair_mouse_entered)
	btn_sair.focus_exited.connect(_on_sair_mouse_exited)

# --- AGE POP-UP LOGIC ---

func _on_confirm_button_pressed():
	# Grab the typed name and strip away any accidental spaces at the beginning/end
	var entered_name = name_input.text.strip_edges()
	
	# Check if they typed a name AND actually selected an age
	if entered_name != "" and age_dropdown.selected > 0:
		
		var selected_age_text = age_dropdown.get_item_text(age_dropdown.selected)
		
		# 1. Save the info to our Global variables
		Global.player_name = entered_name
		Global.player_age = int(selected_age_text)
		
		# 2. Save locally and send the package to Firebase!
		Global.save_game() 
		Global.sync_to_cloud() 
		
		# 3. Hide the pop-up and focus the JOGAR button
		age_popup.hide()
		$Botoes/TextureButton.grab_focus()
	else:
		# Optional: You could change the name_input placeholder text here to warn them!
		print("Preencha o nome e selecione uma idade!")

# --- PLAY BUTTON ---

func _on_texture_button_pressed():
	# 1. FORCE FULLSCREEN!
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

	# 2. Disable the button
	$Botoes/TextureButton.disabled = true
	
	# 3. Play the click sound
	som_botao.play()
	
	# 4. Stop the Menu Music so they don't overlap!
	musica_menu.stop()
	
	# 5. Wait for the click sound to finish
	await som_botao.finished
	
	# 6. Start the seamless endless playlist!
	Global.start_playlist()
	
	# 7. Load the LEVEL SELECT screen!
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")

func _on_texture_button_mouse_entered():
	# Darken the text when hovered
	label_jogar.modulate = Color(0.758, 0.758, 0.758, 1.0)

func _on_texture_button_mouse_exited():
	# Return text to white when mouse leaves
	label_jogar.modulate = Color(1.0, 1.0, 1.0)

# --- MUSIC BUTTON ---

func _on_musica_pressed():
	som_botao.play()
	
	if musica_menu.playing:
		musica_menu.stream_paused = true
		icon_on.hide()
		icon_off.show()
	else:
		musica_menu.stream_paused = false
		icon_on.show()
		icon_off.hide()

func _on_musica_mouse_entered():
	btn_musica.modulate = Color(0.758, 0.758, 0.758, 1.0)

func _on_musica_mouse_exited():
	btn_musica.modulate = Color(1.0, 1.0, 1.0)

# --- EXIT BUTTON ---

func _on_sair_pressed() -> void:
	btn_sair.disabled = true
	som_botao.play()
	await som_botao.finished
	get_tree().quit()

func _on_sair_mouse_entered() -> void:
	btn_sair.modulate = Color(0.758, 0.758, 0.758, 1.0)

func _on_sair_mouse_exited() -> void:
	btn_sair.modulate = Color(1.0, 1.0, 1.0)
