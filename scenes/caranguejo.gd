extends CharacterBody2D

# --- TUNABLE MARIO-STYLE MOVEMENT ---
@export_group("Movement")
@export var speed: float = 175.0
@export var acceleration: float = 2800.0      # Reaches full speed almost instantly (~3 frames)
@export var friction: float = 3200.0          # Stops on a dime (~5 pixels max, no ice slide)
@export var air_acceleration: float = 2200.0  # Snappy mid-air steering
@export var air_friction: float = 2400.0      # Stops drifting mid-air when you let go

@export_group("Jump")
@export var jump_velocity: float = -300.0
@export var jump_cut_multiplier: float = 0.5
@export var fall_gravity_mult: float = 1.6    # Slightly punchier landing
@export var apex_threshold: float = 25.0
@export var apex_gravity_mult: float = 0.75   # Subtle hang without feeling floaty
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.12

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

# Pegando os 5 nós separados (conforme sua Árvore de Cenas)
@onready var part_run_l = $ParticulasRunL
@onready var part_run_r = $ParticulasRunR
@onready var part_jump_l = $ParticulasJumpL
@onready var part_jump_r = $ParticulasJumpR
@onready var part_fall = $ParticulasFall

# Internal timers & touch tracking
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var jump_touch_index: int = -1

func _ready() -> void:
	part_jump_l.animation_finished.connect(_on_part_jump_l_finished)
	part_jump_r.animation_finished.connect(_on_part_jump_r_finished)
	part_fall.animation_finished.connect(_on_part_fall_finished)
	esconder_poeiras()

func esconder_poeiras():
	part_run_l.hide()
	part_run_r.hide()
	part_jump_l.hide()
	part_jump_r.hide()
	part_fall.hide()

func _physics_process(delta: float) -> void:
	var estava_no_ar: bool = not is_on_floor()

	# 1. COYOTE TIME (Reset while on floor, count down in the air)
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta

	# 2. JUMP BUFFERING (Remember jump press briefly before touching ground)
	if Input.is_action_just_pressed("pular"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= delta

	# 3. GRAVIDADE ESTILO MARIO (Flutua leve no topo, cai rápido e firme)
	if not is_on_floor():
		var grav = get_gravity()
		if abs(velocity.y) < apex_threshold:
			velocity += grav * apex_gravity_mult * delta # Hang-time no ápice do pulo
		elif velocity.y > 0:
			velocity += grav * fall_gravity_mult * delta # Queda mais rápida
		else:
			velocity += grav * delta

	# 4. PULO (Com Coyote Time + Jump Buffer)
	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		velocity.y = jump_velocity
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
		
		part_run_l.hide()
		part_run_r.hide()
		
		if anim.flip_h:
			part_jump_r.show()
			part_jump_r.play("jump")
		else:
			part_jump_l.show()
			part_jump_l.play("jump")

	# 5. PULO VARIÁVEL (Soltou o botão cedo = pulinho curto!)
	if Input.is_action_just_released("pular") and velocity.y < 0:
		velocity.y *= jump_cut_multiplier

	# 6. MOVIMENTO SUAVE (Aceleração e Atrito)
	var direction := Input.get_axis("andar_esquerda", "andar_direita")
	var current_accel = acceleration if is_on_floor() else air_acceleration
	var current_friction = friction if is_on_floor() else air_friction

	if direction != 0:
		# Virada rápida: se estiver indo pro lado oposto do momento atual, freia mais rápido
		if sign(direction) != sign(velocity.x) and velocity.x != 0:
			velocity.x = move_toward(velocity.x, direction * speed, (current_accel + current_friction) * delta)
		else:
			velocity.x = move_toward(velocity.x, direction * speed, current_accel * delta)
		anim.flip_h = direction > 0
	else:
		velocity.x = move_toward(velocity.x, 0, current_friction * delta)

	move_and_slide()

	# ATERRISSAGEM (IMPACTO)
	if is_on_floor() and estava_no_ar:
		part_jump_l.hide()
		part_jump_r.hide()
		part_fall.show()
		part_fall.play("fall")

	atualizar_animacoes(direction)

func atualizar_animacoes(direction: float) -> void:
	if not is_on_floor():
		if velocity.y < 0:
			anim.play("jump")
		else:
			anim.play("fall")
		part_run_l.hide()
		part_run_r.hide()
	else:
		if direction != 0:
			anim.play("run")
			if not part_fall.visible:
				if anim.flip_h:
					part_run_l.hide()
					part_run_r.show()
					part_run_r.play("run")
				else:
					part_run_r.hide()
					part_run_l.show()
					part_run_l.play("run")
		else:
			anim.play("idle")
			part_run_l.hide()
			part_run_r.hide()

func _on_part_jump_l_finished():
	part_jump_l.hide()

func _on_part_jump_r_finished():
	part_jump_r.hide()

func _on_part_fall_finished():
	part_fall.hide()

func die():
	set_physics_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimatedSprite2D.play("dead")
	esconder_poeiras()
	
	var move_tween = create_tween()
	move_tween.tween_property(self, "position:y", position.y - 80, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	move_tween.tween_property(self, "position:y", position.y + 600, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	var spin_tween = create_tween()
	spin_tween.tween_property(self, "rotation", 15.0, 1.4)
	
	await get_tree().create_timer(1.5).timeout
	get_tree().call_deferred("reload_current_scene")

func _input(event):
	var screen_width = get_viewport().get_visible_rect().size.x
	var half_screen = screen_width / 2.0
	var quarter_screen = screen_width / 4.0

	if event is InputEventScreenTouch:
		if event.pressed:
			if event.position.x < half_screen:
				if event.position.x < quarter_screen:
					Input.action_press("andar_esquerda")
				else:
					Input.action_press("andar_direita")
			else:
				# Segura o pulo enquanto o dedo estiver na tela (para permitir pulo alto/curto!)
				jump_touch_index = event.index
				Input.action_press("pular")
				
		elif not event.pressed:
			if event.index == jump_touch_index:
				jump_touch_index = -1
				Input.action_release("pular")
			elif event.position.x < half_screen:
				Input.action_release("andar_esquerda")
				Input.action_release("andar_direita")

	elif event is InputEventScreenDrag:
		if event.index != jump_touch_index:
			if event.position.x < half_screen:
				if event.position.x < quarter_screen:
					Input.action_release("andar_direita")
					Input.action_press("andar_esquerda")
				else:
					Input.action_release("andar_esquerda")
					Input.action_press("andar_direita")
			else:
				Input.action_release("andar_esquerda")
				Input.action_release("andar_direita")
