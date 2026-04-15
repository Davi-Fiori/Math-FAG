extends Node2D

@onready var question_mark_1 = $"HUD/HBoxContainer/TextureRect/numero 1" # First "?"
@onready var question_mark_2 = $HUD/HBoxContainer/TextureRect3/interrogacao # Second "?"
@onready var key = $chave
@onready var door = $porta
@onready var timer = $Timer
@onready var time_label = $HUD/TimeLabel

# The numbers needed to win (order doesn't matter)
var required_numbers = [5,7]

# The numbers the crab has picked up so far
var collected_numbers = []

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
	# 1. Check if the grabbed number is one of the correct ones
	# AND make sure they haven't already grabbed it (just in case!)
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
			get_tree().call_group("numbers", "queue_free")
			spawn_key()
			
	else:
		# WRONG ANSWER - It wasn't a 5 or a 7!
		$caranguejo.die()

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
