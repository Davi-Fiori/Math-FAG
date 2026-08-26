extends Node2D

@onready var question_mark_1 = $"HUD/HBoxContainer/TextureRect/numero 1"
@onready var question_mark_2 = $HUD/HBoxContainer/TextureRect3/interrogacao
@onready var key = $chave
@onready var door = $porta
@onready var timer = $Timer
@onready var time_label = $HUD/TimeLabel
@onready var player = $caranguejo

var can_enter_door = false
var required_numbers = [5,7]
var collected_numbers = []

func _ready():
	key.hide()
	key.process_mode = Node.PROCESS_MODE_DISABLED
	door.hide()
	door.process_mode = Node.PROCESS_MODE_DISABLED
	
	timer.timeout.connect(_on_timer_timeout)
	# The Level is now the ONLY script listening for the door touch!
	door.body_entered.connect(_on_door_body_entered)

func _on_timer_timeout():
	# Pass "tempo" so Firebase logs it as levelX_tempo
	record_error("tempo") 
	$caranguejo.die()
	await get_tree().create_timer(2.0).timeout
	restart_level()

func check_answer(picked_value):
	# 1. Check if the grabbed number is one of the correct ones
	if picked_value in required_numbers and not picked_value in collected_numbers:
		
		# Add it to our collected list
		collected_numbers.append(picked_value)
		
		# 2. Update the HUD from left to right
		if collected_numbers.size() == 1:
			question_mark_1.text = str(picked_value)
		elif collected_numbers.size() == 2:
			question_mark_2.text = str(picked_value)
			
		# 3. Check if we have collected ALL the required numbers
		if collected_numbers.size() == required_numbers.size():
			# (We removed timer.stop() from here so the clock keeps ticking!)
			get_tree().call_group("numbers", "queue_free")
			spawn_key()
			
	else:
		# WRONG ANSWER
		record_error("erros") 
		$caranguejo.die()

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
			# WE NOW CALL THE DOOR SCRIPT AND SEND IT THE TIME!
			door.advance_level(timer.time_left)

func _on_door_body_entered(body):
	if body.name == "caranguejo" and can_enter_door == true:
		# WE NOW CALL THE DOOR SCRIPT AND SEND IT THE TIME!
		door.advance_level(timer.time_left)

func restart_level():
	get_tree().call_deferred("reload_current_scene")

func _process(_delta):
	time_label.text = str(int(timer.time_left))
	
func record_error(error_type: String):
	# Automatically figure out if this is level_1, level_2, etc.
	var current_path = get_tree().current_scene.scene_file_path
	var level_number = current_path.get_file().get_basename().trim_prefix("level_").to_int()
	
	# Send both the level number AND the type of error to Global!
	Global.log_error(level_number, error_type)
