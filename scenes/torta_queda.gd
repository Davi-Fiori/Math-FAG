extends Area2D

var is_falling: bool = false
var current_fall_speed: float = 0.0
@export var gravity_multiplier: float = 2.0

@onready var drop_detector = $DropDetector

func _ready() -> void:
	# Only connect if not already connected in the Editor
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if not is_falling:
		# Check if the raycast pointing down detects the player underneath
		if drop_detector and drop_detector.is_colliding():
			var collider = drop_detector.get_collider()
			if collider and collider.is_in_group("player"):
				is_falling = true
	else:
		# Renamed to 'fall_gravity' so it doesn't clash with Area2D's built-in gravity
		var fall_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
		current_fall_speed += fall_gravity * gravity_multiplier * delta
		position.y += current_fall_speed * delta

func _on_body_entered(body: Node2D) -> void:
	# Check if the thing touched is your player
	if body.is_in_group("player"):
		if not body.has_meta("is_dead"):
			body.set_meta("is_dead", true)
			
			# Log error and trigger player death animation
			var current_path = get_tree().current_scene.scene_file_path
			var level_number = current_path.get_file().get_basename().trim_prefix("level_").to_int()
			Global.log_error(level_number, "obstaculos")
			
			body.die()
		
		# Remove the falling pie object upon impact
		queue_free()
