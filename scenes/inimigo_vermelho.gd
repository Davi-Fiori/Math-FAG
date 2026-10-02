extends CharacterBody2D

@export var speed: float = 40.0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var direction: int = -1 # -1 = Left, 1 = Right

@onready var pivot = $Pivot
@onready var edge_detector = $EdgeDetector

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_on_wall() or not edge_detector.is_colliding():
		turn_around()

	velocity.x = direction * speed
	move_and_slide()

func turn_around() -> void:
	direction *= -1
	pivot.scale.x *= -1
	edge_detector.position.x = 10.0 * direction
	position.x += direction * 4.0

# --- PLAYER KILL LOGIC ---
func _on_hitbox_body_entered(body: Node2D) -> void:
	# Check if the colliding body belongs to the "player" group
	if body.is_in_group("player"):
		# Check if the player has a death function we can call
		if body.has_method("die"):
			body.die()
