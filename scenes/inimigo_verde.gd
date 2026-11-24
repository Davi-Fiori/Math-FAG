extends CharacterBody2D

@export var patrol_speed: float = 20.0
@export var chase_speed: float = 45.0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var direction: int = -1 # -1 = Left, 1 = Right

# States for our enemy
enum State { PATROL, CHASE, ATTACK }
var current_state: State = State.PATROL

@onready var pivot = $Pivot
@onready var animated_sprite = $Pivot/AnimatedSprite2D
@onready var edge_detector = $EdgeDetector
@onready var sight_detector = $SightDetector
@onready var hitbox_shape = $Hitbox/CollisionShape2D

func _ready() -> void:
	hitbox_shape.disabled = false
	# Force the sight detector to match the starting direction (-1 means left)
	sight_detector.target_position.x = -50.0 if direction < 0 else 50.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	# State Machine logic
	match current_state:
		State.PATROL:
			patrol_behavior(delta)
		State.CHASE:
			chase_behavior(delta)
		State.ATTACK:
			# Stop moving while attacking
			velocity.x = move_toward(velocity.x, 0, patrol_speed * delta)

	move_and_slide()

func patrol_behavior(delta: float) -> void:
	# Walk slowly using the idle animation
	animated_sprite.play("idle")
	velocity.x = direction * patrol_speed

	# Check for walls or cliffs to turn around
	if is_on_wall() or not edge_detector.is_colliding():
		turn_around()

	# Check if the sight raycast spots the player in front
	if sight_detector.is_colliding():
		var collider = sight_detector.get_collider()
		if collider and collider.is_in_group("player"):
			current_state = State.CHASE

func chase_behavior(delta: float) -> void:
	# Run towards the player using the run animation
	animated_sprite.play("run")
	velocity.x = direction * chase_speed

	# Keep edge/wall checks active so it doesn't fall off cliffs while chasing
	if is_on_wall() or not edge_detector.is_colliding():
		turn_around()

	# Check if close enough to attack (or if sight detects player up close)
	if sight_detector.is_colliding():
		var collider = sight_detector.get_collider()
		if collider and collider.is_in_group("player"):
			var distance = global_position.distance_to(collider.global_position)
			if distance < 30.0: # Close attack threshold
				start_attack()
	else:
		# If player escapes sight range, go back to patrol
		current_state = State.PATROL

func start_attack() -> void:
	current_state = State.ATTACK
	animated_sprite.play("attack")
	
	# 1. Wait a moment for the attack animation wind-up before enabling damage
	await get_tree().create_timer(0.2).timeout
	if current_state == State.ATTACK:
		hitbox_shape.disabled = false # Turn ON damage during strike frames
	
	# 2. Keep damage active for the duration of the 7-frame attack sequence
	await get_tree().create_timer(0.4).timeout 
	hitbox_shape.disabled = true # Turn OFF damage
	
	# 3. Resume patrolling after attack finishes
	await get_tree().create_timer(0.2).timeout
	if current_state == State.ATTACK:
		current_state = State.PATROL

func turn_around() -> void:
	direction *= -1
	pivot.scale.x *= -1
	
	# Position the edge detector
	edge_detector.position.x = 16.0 * direction
	position.x += direction * 8.0
	
	# Explicitly force the sight detector target position left or right
	if direction < 0:
		sight_detector.target_position.x = -50.0 # Point Left
	else:
		sight_detector.target_position.x = 50.0  # Point Right

# --- PLAYER KILL LOGIC ---
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not hitbox_shape.disabled:
		if body.has_method("die"):
			body.die()
