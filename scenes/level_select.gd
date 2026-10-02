extends Control

@onready var grid = $TextureRect/GridContainer
@onready var som_botao = $SomBotao

# --- EXTRA BUTTON NODES ---
@onready var btn_voltar = $BotaoVoltar
@onready var btn_esq = $charSelect/esquerda
@onready var btn_dir = $charSelect/direita

# --- CHARACTER SELECTION NODES ---
@onready var nome_label = $charSelect/TextureRect/escolha2
@onready var anim_leo = $"charSelect/caranguejo menu"
@onready var anim_joe = $"charSelect/joe menu" # Make sure this node exists in your scene!

var character_list = []
var current_index = 0

func _ready():
	Global.load_game()
	
	# 1. Define the characters (Name, Visual Node, and Scene Path to spawn)
	character_list = [
		{"name": "LEO", "node": anim_leo, "scene": "res://scenes/caranguejo.tscn"},
		{"name": "JOE", "node": anim_joe, "scene": "res://scenes/joe_sapo.tscn"}
	]
	
	# 2. Load the last chosen character from Global memory
	current_index = Global.selected_char_index
	update_character_display()
	
	# 3. Connect the arrow buttons' press actions
	btn_esq.pressed.connect(_on_esquerda_pressed)
	btn_dir.pressed.connect(_on_direita_pressed)

	# 4. Setup "Voltar" Button (Standard Darken Hover)
	if not btn_voltar.mouse_entered.is_connected(_on_level_hover_entered):
		btn_voltar.mouse_entered.connect(_on_level_hover_entered.bind(btn_voltar))
		btn_voltar.mouse_exited.connect(_on_level_hover_exited.bind(btn_voltar))
		btn_voltar.focus_entered.connect(_on_level_hover_entered.bind(btn_voltar))
		btn_voltar.focus_exited.connect(_on_level_hover_exited.bind(btn_voltar))

	# 5. Setup Arrow Buttons (Special Whiten Hover)
	var arrows = [btn_esq, btn_dir]
	for arrow in arrows:
		if not arrow.mouse_entered.is_connected(_on_arrow_hover_entered):
			arrow.mouse_entered.connect(_on_arrow_hover_entered.bind(arrow))
			arrow.mouse_exited.connect(_on_arrow_hover_exited.bind(arrow))
			arrow.focus_entered.connect(_on_arrow_hover_entered.bind(arrow))
			arrow.focus_exited.connect(_on_arrow_hover_exited.bind(arrow))

	# 6. Level Unlock & Grid Logic
	var botoes = grid.get_children()
	var first_unlocked_btn = null
	
	for i in range(botoes.size()):
		var btn = botoes[i] as TextureButton
		var level_num = i + 1 
		
		if level_num > Global.levels_unlocked:
			btn.disabled = true
			btn.modulate = Color(0.3, 0.3, 0.3, 1.0) 
		else:
			btn.disabled = false
			btn.modulate = Color(1.0, 1.0, 1.0, 1.0)
			
			# Save the very first unlocked button we find to give it controller focus later
			if first_unlocked_btn == null:
				first_unlocked_btn = btn
			
			# Connect the press event
			if not btn.pressed.is_connected(_on_level_btn_pressed):
				btn.pressed.connect(_on_level_btn_pressed.bind(level_num))
				
			# Connect Mouse and Controller Hover events dynamically
			if not btn.mouse_entered.is_connected(_on_level_hover_entered):
				btn.mouse_entered.connect(_on_level_hover_entered.bind(btn))
				btn.mouse_exited.connect(_on_level_hover_exited.bind(btn))
				btn.focus_entered.connect(_on_level_hover_entered.bind(btn))
				btn.focus_exited.connect(_on_level_hover_exited.bind(btn))
				
	# 7. Initialize Controller Navigation
	if first_unlocked_btn != null:
		first_unlocked_btn.grab_focus()

# --- CONTROLLER SUBMENU SWITCHING ---
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_focus_next"):
		btn_esq.grab_focus()
	elif event.is_action_pressed("ui_focus_prev"):
		var botoes = grid.get_children()
		for btn in botoes:
			if not btn.disabled:
				btn.grab_focus()
				break

# --- CHARACTER SELECTION LOGIC ---
func _on_esquerda_pressed():
	current_index -= 1
	if current_index < 0:
		current_index = character_list.size() - 1
	update_character_display()

func _on_direita_pressed():
	current_index += 1
	if current_index >= character_list.size():
		current_index = 0
	update_character_display()

func update_character_display():
	for char_data in character_list:
		char_data["node"].hide()
		
	character_list[current_index]["node"].show()
	nome_label.text = character_list[current_index]["name"]
	
	Global.selected_char_index = current_index
	Global.selected_char_scene = character_list[current_index]["scene"]

# --- SCENE TRANSITIONS ---
func _on_level_btn_pressed(level_num: int):
	for btn in grid.get_children():
		if btn is TextureButton:
			btn.disabled = true
			
	som_botao.play()
	await som_botao.finished
	
	var level_path = "res://scenes/level_" + str(level_num) + ".tscn"
	get_tree().change_scene_to_file(level_path)

func _on_botao_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

# --- HOVER & FOCUS EFFECTS ---
func _on_level_hover_entered(btn: TextureButton) -> void:
	if not btn.disabled:
		btn.modulate = Color(0.758, 0.758, 0.758, 1.0) # Darkens

func _on_level_hover_exited(btn: TextureButton) -> void:
	if not btn.disabled:
		btn.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _on_arrow_hover_entered(btn: TextureButton) -> void:
	# Pushing numbers over 1.0 brightens dark textures significantly.
	btn.modulate = Color(3.5, 3.5, 3.5, 1.0) 

func _on_arrow_hover_exited(btn: TextureButton) -> void:
	btn.modulate = Color(1.0, 1.0, 1.0, 1.0)
