extends Node2D

@onready var key = $chave
@onready var door = $porta
@onready var timer = $Timer
@onready var question_mark_label = $HUD/HBoxContainer/TextureRect3/interrogacao
@onready var time_label = $HUD/TimeLabel

# The ONLY thing different between your levels now is this number!
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
	restart_level()

func check_answer(picked_value):
	if picked_value == correct_answer:
		question_mark_label.text = str(correct_answer)
		get_tree().call_group("numbers", "queue_free")
		spawn_key()
	else:
		$caranguejo.die()

func spawn_key():
	key.show()
	key.process_mode = Node.PROCESS_MODE_INHERIT

func show_door():
	door.show()
	door.process_mode = Node.PROCESS_MODE_INHERIT
	door.get_node("AnimatedSprite2D").play("abrindo")
	
	# Wait 2 seconds while the animation plays
	await get_tree().create_timer(1.0).timeout
	
	# The 2 seconds are up! Unlock the door.
	can_enter_door = true
	
	# Check if the crab is ALREADY standing inside the door!
	for body in door.get_overlapping_bodies():
		if body.name == "caranguejo":
			go_to_next_level()

# --- DOOR TOUCH LOGIC ---
func _on_door_body_entered(body):
	# Check if it is the crab AND the door is fully unlocked
	if body.name == "caranguejo" and can_enter_door == true:
		go_to_next_level()

# --- "SMART DOOR" MATH ---
func go_to_next_level():
	var current_path = get_tree().current_scene.scene_file_path 
	var level_number = current_path.get_file().get_basename().trim_prefix("level_").to_int()
	var next_level_number = level_number + 1
	var next_level_path = "res://scenes/level_" + str(next_level_number) + ".tscn"
	
	if ResourceLoader.exists(next_level_path):
		get_tree().change_scene_to_file(next_level_path)
	else:
		print("YOU BEAT THE GAME!")
		# get_tree().change_scene_to_file("res://scenes/victory_screen.tscn")
# -------------------------------------------------------------

func restart_level():
	get_tree().call_deferred("reload_current_scene")
	
func _process(delta):
	time_label.text = str(int(timer.time_left))
