extends Control

signal menu_fechado
signal abrir_personagens # <-- NOVO SINAL para abrir a seleção de bonecos

@onready var btn_continuar = $TextureRect/VBoxContainer/BtnContinuar
@onready var btn_personagem = $TextureRect/VBoxContainer/BtnPersonagem
@onready var btn_menu_principal = $TextureRect/BtnMenuPrincipal
@onready var btn_reiniciar = $TextureRect/BtnReiniciar

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	_desbloquear_cliques()
	hide()
	
	if not btn_continuar.pressed.is_connected(_on_continuar_pressed):
		btn_continuar.pressed.connect(_on_continuar_pressed)
	if not btn_personagem.pressed.is_connected(_on_trocar_personagem_pressed):
		btn_personagem.pressed.connect(_on_trocar_personagem_pressed)
	if not btn_reiniciar.pressed.is_connected(_on_reiniciar_pressed):
		btn_reiniciar.pressed.connect(_on_reiniciar_pressed)
	if not btn_menu_principal.pressed.is_connected(_on_menu_principal_pressed):
		btn_menu_principal.pressed.connect(_on_menu_principal_pressed)

func _desbloquear_cliques():
	for btn in [btn_continuar, btn_personagem, btn_reiniciar, btn_menu_principal]:
		if btn:
			for filho in btn.find_children("*", "Control", true):
				filho.mouse_filter = Control.MOUSE_FILTER_IGNORE

func abrir():
	get_tree().paused = true
	show()

func fechar():
	hide()
	if is_inside_tree() and get_tree():
		get_tree().paused = false
	menu_fechado.emit()

# 1. CONTINUAR
func _on_continuar_pressed():
	fechar()

# 2. PERSONAGENS (Esconde o pause e pede para abrir a janela de personagens!)
func _on_trocar_personagem_pressed():
	hide()
	abrir_personagens.emit()

# 3. REINICIAR
func _on_reiniciar_pressed():
	if not is_inside_tree() or get_tree() == null:
		return
	get_tree().paused = false
	get_tree().reload_current_scene()

# 4. HOME (Menu Principal)
func _on_menu_principal_pressed():
	if not is_inside_tree() or get_tree() == null:
		return
	get_tree().paused = false
	Global.stop_playlist()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
