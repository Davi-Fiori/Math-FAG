extends Node2D

# Edit these 2 numbers in the Inspector for each level!
@export var required_numbers: Array[int] = [33, 72]

# Make sure these paths match the '?' labels in this level's HUD!
@onready var question_mark_1 = $"HUD/HBoxContainer/TextureRect5/numero 1"
@onready var question_mark_2 = $"HUD/HBoxContainer2/TextureRect5/numero 1"

@onready var key = $chave
@onready var door = $porta
@onready var timer = $Timer
@onready var time_label = $HUD/TimeLabel
@onready var painel_pause = $HUD/Painel_pause
@onready var btn_pause = $HUD/Menus/pause
@onready var pause_icon = $HUD/Menus/pause/pause_icon
@onready var play_icon = $HUD/Menus/pause/play_icon
@onready var btn_menu = $HUD/Menus/botaomenu
@onready var char_select = $HUD/CharSelect

var can_enter_door = false
var collected_numbers = []

func _ready():
	# --- DYNAMIC CHARACTER SPAWNING ---
	var player_scene = load(Global.selected_char_scene)
	var player_instance = player_scene.instantiate()
	player_instance.global_position = $SpawnPoint.global_position
	add_child(player_instance)
	# ----------------------------------

	key.hide()
	key.process_mode = Node.PROCESS_MODE_DISABLED
	door.hide()
	door.process_mode = Node.PROCESS_MODE_DISABLED
	
	timer.timeout.connect(_on_timer_timeout)
	door.body_entered.connect(_on_door_body_entered)
	
	pause_icon.show()
	play_icon.hide()
	
	if not btn_pause.pressed.is_connected(_on_pause_pressed):
		btn_pause.pressed.connect(_on_pause_pressed)
	if not btn_menu.pressed.is_connected(_on_menu_pressed):
		btn_menu.pressed.connect(_on_menu_pressed)
	if not painel_pause.menu_fechado.is_connected(_on_painel_fechado):
		painel_pause.menu_fechado.connect(_on_painel_fechado)
	if not painel_pause.abrir_personagens.is_connected(char_select.abrir):
		painel_pause.abrir_personagens.connect(char_select.abrir)

func _on_timer_timeout():
	record_error("tempo") 
	var current_player = get_tree().get_first_node_in_group("player")
	if current_player:
		current_player.die()
	await get_tree().create_timer(2.0).timeout
	restart_level()

func check_answer(picked_value):
	if picked_value in required_numbers and not picked_value in collected_numbers:
		collected_numbers.append(picked_value)
		
		if picked_value == required_numbers[0]:
			question_mark_1.text = str(picked_value)
		elif picked_value == required_numbers[1]:
			question_mark_2.text = str(picked_value)
			
		if collected_numbers.size() == required_numbers.size():
			get_tree().call_group("numbers", "queue_free")
			spawn_key()
	else:
		record_error("erros") 
		var current_player = get_tree().get_first_node_in_group("player")
		if current_player:
			current_player.die()

func spawn_key():
	key.show()
	key.process_mode = Node.PROCESS_MODE_INHERIT

func show_door():
	door.show()
	door.process_mode = Node.PROCESS_MODE_INHERIT
	door.get_node("AnimatedSprite2D").play("abrindo")
	
	await get_tree().create_timer(1.0).timeout
	can_enter_door = true
	
	for body in door.get_overlapping_bodies():
		if body.is_in_group("player"):
			door.advance_level(timer.time_left)

func _on_door_body_entered(body):
	if body.is_in_group("player") and can_enter_door == true:
		door.advance_level(timer.time_left)

func restart_level():
	get_tree().call_deferred("reload_current_scene")

func _process(_delta):
	time_label.text = str(int(timer.time_left))

func record_error(error_type: String):
	var current_path = get_tree().current_scene.scene_file_path
	var level_number = current_path.get_file().get_basename().trim_prefix("level_").to_int()
	Global.log_error(level_number, error_type)

# --- PAUSE & MENU ---
func _on_pause_pressed():
	if get_tree().paused:
		get_tree().paused = false
		timer.paused = false
		pause_icon.show()
		play_icon.hide()
	else:
		get_tree().paused = true
		timer.paused = true
		pause_icon.hide()
		play_icon.show()

func _on_menu_pressed():
	pause_icon.hide()
	play_icon.show()
	timer.paused = true
	painel_pause.abrir()

func _on_painel_fechado():
	timer.paused = false
	pause_icon.show()
	play_icon.hide()
