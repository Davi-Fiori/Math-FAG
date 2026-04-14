extends CharacterBody2D

const SPEED = 175.0
const JUMP_VELOCITY = -300.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

# Pegando os 5 nós separados (conforme sua nova Árvore de Cenas)
@onready var part_run_l = $ParticulasRunL
@onready var part_run_r = $ParticulasRunR
@onready var part_jump_l = $ParticulasJumpL
@onready var part_jump_r = $ParticulasJumpR
@onready var part_fall = $ParticulasFall

func _ready() -> void:
	# Conecta os sinais para sumirem quando a animação acabar
	part_jump_l.animation_finished.connect(_on_part_jump_l_finished)
	part_jump_r.animation_finished.connect(_on_part_jump_r_finished)
	part_fall.animation_finished.connect(_on_part_fall_finished)
	
	# Esconde todos no começo
	esconder_poeiras()

# Função auxiliar para manter o código limpo
func esconder_poeiras():
	part_run_l.hide()
	part_run_r.hide()
	part_jump_l.hide()
	part_jump_r.hide()
	part_fall.hide()

func _physics_process(delta: float) -> void:
	var estava_no_ar: bool = not is_on_floor()

	if not is_on_floor():
		velocity += get_gravity() * delta

	# PULO
	if Input.is_action_just_pressed("pular") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		part_run_l.hide() # Desliga a poeira de corrida
		part_run_r.hide() 
		
		# Checa para qual lado está olhando e toca a poeira certa
		if anim.flip_h: # Virado para a direita
			part_jump_r.show()
			part_jump_r.play("jump")
		else: # Virado para a esquerda
			part_jump_l.show()
			part_jump_l.play("jump")

	# MOVIMENTO
	var direction := Input.get_axis("andar_esquerda", "andar_direita")
	
	if direction:
		velocity.x = direction * SPEED
		anim.flip_h = direction > 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# (Removemos aquele bloco antigo de flip_h das partículas, pois os nós L e R resolvem isso!)

	move_and_slide()

	# ATERRISSAGEM (IMPACTO)
	if is_on_floor() and estava_no_ar:
		part_jump_l.hide() # Garante que as do pulo sumiram
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
		
		# Se saiu do chão, esconde as poeiras de correr
		part_run_l.hide()
		part_run_r.hide()
	
	else:
		if direction != 0:
			anim.play("run")  
			
			# Só liga a poeira de corrida se a poeira de aterrissagem já sumiu
			if not part_fall.visible:
				if anim.flip_h: # Andando para a direita
					part_run_l.hide() # Desliga a esquerda para garantir
					part_run_r.show()
					part_run_r.play("run")
				else: # Andando para a esquerda
					part_run_r.hide() # Desliga a direita para garantir
					part_run_l.show()
					part_run_l.play("run")
		else:
			anim.play("idle")
			part_run_l.hide()
			part_run_r.hide()

# Funções separadas para esconder as animações que não têm loop
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
	
	# Esconde todas as poeiras ao morrer para o efeito ficar limpo
	esconder_poeiras()
	
	var move_tween = create_tween()
	move_tween.tween_property(self, "position:y", position.y - 80, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	move_tween.tween_property(self, "position:y", position.y + 600, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	var spin_tween = create_tween()
	spin_tween.tween_property(self, "rotation", 15.0, 1.4)
	
	await get_tree().create_timer(1.5).timeout
	get_tree().call_deferred("reload_current_scene")
