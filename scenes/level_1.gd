extends Node2D

@onready var key = $chave
@onready var door = $porta
@onready var timer = $Timer
@onready var question_mark_label = $HUD/HBoxContainer/TextureRect3/interrogacao
@onready var time_label = $HUD/TimeLabel

var correct_answer = 1
var can_enter_door = false 

func _ready():
	key.hide()
	key.process_mode = Node.PROCESS_MODE_DISABLED
	door.hide()
	door.process_mode = Node.PROCESS_MODE_DISABLED
	
	timer.timeout.connect(_on_timer_timeout)
	door.body_entered.connect(_on_door_body_entered)

func _on_timer_timeout():
	record_error() # <--- Tell Firebase they ran out of time!
	$caranguejo.die()
	await get_tree().create_timer(2.0).timeout
	restart_level()

func check_answer(picked_value):
	if picked_value == correct_answer:
		question_mark_label.text = str(correct_answer)
		get_tree().call_group("numbers", "queue_free")
		spawn_key()
	else:
		record_error() # <--- Tell Firebase they picked the wrong number!
		$caranguejo.die()

func spawn_key():
	key.show()
	key.process_mode = Node.PROCESS_MODE_INHERIT

func show_door():
	door.show()
	door.process_mode = Node.PROCESS_MODE_INHERIT
	door.get_node("AnimatedSprite2D").play("abrindo")
	
	# Wait 1 second while the animation plays
	await get_tree().create_timer(1.0).timeout
	
	# The 1 second is up! Unlock the door.
	can_enter_door = true
	
	# Check if the crab is ALREADY standing inside the door!
	for body in door.get_overlapping_bodies():
		if body.name == "caranguejo":
			door.advance_level(timer.time_left)

# --- DOOR TOUCH LOGIC ---
func _on_door_body_entered(body):
	# Check if it is the crab AND the door is fully unlocked
	if body.name == "caranguejo" and can_enter_door == true:
		door.advance_level(timer.time_left)

func restart_level():
	get_tree().call_deferred("reload_current_scene")
	
func _process(_delta):
	time_label.text = str(int(timer.time_left))
	
func record_error():
	# Automatically figure out if this is level_1, level_2, etc.
	var current_path = get_tree().current_scene.scene_file_path
	var level_number = current_path.get_file().get_basename().trim_prefix("level_").to_int()
	
	# Send it to the Global script!
	Global.log_error(level_number)
