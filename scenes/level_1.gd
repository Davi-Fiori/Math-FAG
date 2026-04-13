extends Node2D

@onready var key = $chave
@onready var door = $porta
@onready var timer = $Timer
@onready var question_mark_label = $HUD/HBoxContainer/TextureRect3/interrogacao
@onready var time_label = $HUD/TimeLabel

var correct_answer = 1

func _ready():
	# Hide and disable the key and door at the start
	key.hide()
	key.process_mode = Node.PROCESS_MODE_DISABLED
	door.hide()
	door.process_mode = Node.PROCESS_MODE_DISABLED
	
	# Connect the timer
	timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout():
	restart_level()

func check_answer(picked_value):
	if picked_value == correct_answer:
		# Change the "?" to the correct answer (converts the number to text)
		question_mark_label.text = str(correct_answer)
		
		# Delete the floating numbers and spawn the key
		get_tree().call_group("numbers", "queue_free")
		spawn_key()
	else:
		# Wrong answer
		get_tree().call_deferred("reload_current_scene")

func spawn_key():
	key.show()
	key.process_mode = Node.PROCESS_MODE_INHERIT

func show_door():
	door.show()
	door.process_mode = Node.PROCESS_MODE_INHERIT
	door.get_node("AnimatedSprite2D").play("abrindo")

func restart_level():
	get_tree().call_deferred("reload_current_scene")
	
func _process(delta):
	# We use int() to chop off the decimals, otherwise it shows as 29.847291
	# Then we use str() to turn that number into text for the Label
	time_label.text = str(int(timer.time_left))
