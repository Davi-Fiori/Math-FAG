extends CharacterBody2D

const SPEED = 175.0
const JUMP_VELOCITY = -420.0 # Increased so Joe jumps higher!

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

# Pegando apenas os 3 nós de poeira que o Joe realmente tem
@onready var part_jump_l = $ParticulasJumpL
@onready var part_jump_r = $ParticulasJumpR

# --- TOUCH CONTROLS ---
var swipe_start_pos = Vector2.ZERO
var min_swipe_distance = 40 

func _ready() -> void:
	# Conecta os sinais para sumirem quando a animação acabar
	part_jump_l.animation_finished.connect(_on_part_jump_l_finished)
	part_jump_r.animation_finished.connect(_on_part_jump_r_finished)
	
	# Esconde todos no começo
	esconder_poeiras()

func esconder_poeiras():
	part_jump_l.hide()
	part_jump_r.hide()

func _physics_process(delta: float) -> void:
	var estava_no_ar: bool = not is_on_floor()

	if not is_on_floor():
		velocity += get_gravity() * delta

	# PULO
	if Input.is_action_just_pressed("pular") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
		# Checa para qual lado está olhando e toca a poeira certa
		# Agora flip_h = true significa virado para a ESQUERDA
		if anim.flip_h: 
			part_jump_l.show()
			part_jump_l.play("jump")
		else: 
			part_jump_r.show()
			part_jump_r.play("jump")

	# MOVIMENTO
	var direction := Input.get_axis("andar_esquerda", "andar_direita")
	
	if direction:
		velocity.x = direction * SPEED
		# INVERTIDO AQUI: flip_h ativa apenas quando anda para a esquerda (< 0)
		anim.flip_h = direction < 0 
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# ATERRISSAGEM (IMPACTO)
	if is_on_floor() and estava_no_ar:
		part_jump_l.hide() 
		part_jump_r.hide() 

	atualizar_animacoes(direction)

func atualizar_animacoes(direction: float) -> void:
	if not is_on_floor():
		if velocity.y < 0:
			anim.play("jump")
	else:
		if direction != 0:
			anim.play("run")  
		else:
			anim.play("idle")

# Funções separadas para esconder as animações que não têm loop
func _on_part_jump_l_finished():
	part_jump_l.hide()

func _on_part_jump_r_finished():
	part_jump_r.hide()

func die():
	set_physics_process(false) 
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimatedSprite2D.play("dead") 
	
	# Esconde todas as poeiras ao morrer para o efeito ficar limpo
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
				Input.action_press("pular")
				await get_tree().process_frame
				Input.action_release("pular")
				
		elif not event.pressed:
			if event.position.x < half_screen:
				Input.action_release("andar_esquerda")
				Input.action_release("andar_direita")

	elif event is InputEventScreenDrag:
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
