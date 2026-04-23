extends Node2D

@onready var key = $chave
@onready var door = $porta
@onready var player = $caranguejo

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
		# Uses the 'player' variable you set up
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
			door.advance_level(timer.time_left)

func _on_door_body_entered(body):
	if body.name == "caranguejo" and can_enter_door == true:
		door.advance_level(timer.time_left)

func restart_level():
	get_tree().call_deferred("reload_current_scene")
	
func _process(_delta):
	time_label.text = str(int(timer.time_left))
