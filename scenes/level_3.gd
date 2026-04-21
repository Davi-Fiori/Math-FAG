extends Node2D

@onready var key = $chave
@onready var door = $Tiles/porta

# ATENÇÃO: Se o erro "null instance" voltar, é este caminho abaixo que você precisa
# arrumar segurando Ctrl e arrastando o caranguejo da aba Scene para cá!
@onready var player = $Tiles/caranguejo

@onready var timer = $Timer
@onready var question_mark_label = $HUD/HBoxContainer/TextureRect3/interrogacao
@onready var time_label = $HUD/TimeLabel

var correct_answer = 3
var can_enter_door = false

func _ready():
	key.hide()
	key.process_mode = Node.PROCESS_MODE_DISABLED
	door.hide()
	door.process_mode = Node.PROCESS_MODE_DISABLED
	
	timer.timeout.connect(_on_timer_timeout)
	door.body_entered.connect(_on_door_body_entered)

func _on_timer_timeout():
	restart_level()

func check_answer(picked_value):
	if picked_value == correct_answer:
		question_mark_label.text = str(correct_answer)
		get_tree().call_group("numbers", "queue_free")
		spawn_key()
	else:
		# Usa a variável 'player' que criamos lá em cima
		player.die()

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
		if body.name == "caranguejo":
			go_to_next_level()

func _on_door_body_entered(body):
	if body.name == "caranguejo" and can_enter_door == true:
		go_to_next_level()

func go_to_next_level():
	var current_path = get_tree().current_scene.scene_file_path 
	var level_number = current_path.get_file().get_basename().trim_prefix("level_").to_int()
	var next_level_number = level_number + 1
	var next_level_path = "res://scenes/level_" + str(next_level_number) + ".tscn"
	
	if ResourceLoader.exists(next_level_path):
		get_tree().change_scene_to_file(next_level_path)
	else:
		print("VOCÊ ZEROU O JOGO!")

func restart_level():
	get_tree().call_deferred("reload_current_scene")
	
func _process(delta):
	time_label.text = str(int(timer.time_left))
