extends Control

@onready var nome_label = $charSelect/TextureRect/escolha2
@onready var anim_leo = $"charSelect/caranguejo menu"
@onready var anim_joe = $"charSelect/joe menu"
@onready var btn_esq = $charSelect/esquerda
@onready var btn_dir = $charSelect/direita

# Procura o botão de confirmar
@onready var btn_confirmar = $charSelect.get_node_or_null("confirmar") if $charSelect.has_node("confirmar") else $charSelect.get_node_or_null("Confirmar")

var character_list = []
var current_index = 0

func _ready():
	# Permite interagir com este menu mesmo pausado!
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	
	character_list = [
		{"name": "LEO", "node": anim_leo, "scene": "res://scenes/caranguejo.tscn"},
		{"name": "JOE", "node": anim_joe, "scene": "res://scenes/joe_sapo.tscn"}
	]
	
	current_index = Global.selected_char_index
	update_character_display()
	
	if not btn_esq.pressed.is_connected(_on_esquerda_pressed):
		btn_esq.pressed.connect(_on_esquerda_pressed)
	if not btn_dir.pressed.is_connected(_on_direita_pressed):
		btn_dir.pressed.connect(_on_direita_pressed)
	
	# Fallback para encontrar o botão de confirmar caso tenha outro nome
	if btn_confirmar == null:
		for child in $charSelect.get_children():
			if child is BaseButton and child != btn_esq and child != btn_dir:
				btn_confirmar = child
				break
				
	if btn_confirmar and not btn_confirmar.pressed.is_connected(_on_confirmar_pressed):
		btn_confirmar.pressed.connect(_on_confirmar_pressed)

func abrir():
	current_index = Global.selected_char_index
	update_character_display()
	show()

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

# Ao confirmar: salva e reinicia a fase com o novo boneco no SpawnPoint!
func _on_confirmar_pressed():
	Global.selected_char_index = current_index
	Global.selected_char_scene = character_list[current_index]["scene"]
	Global.save_game()
	
	hide()
	get_tree().paused = false
	get_tree().reload_current_scene()
