extends CharacterBody2D

const SPEED = 175.0
const JUMP_VELOCITY = -300.0

# Referência ao nó de animação. 
# Se o seu nó tiver outro nome, mude "AnimatedSprite2D" para o nome exato dele.
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# 1. Aplicar gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 2. Pulo usando a nova tecla configurada
	if Input.is_action_just_pressed("pular") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 3. Movimento usando as novas teclas configuradas
	var direction := Input.get_axis("andar_esquerda", "andar_direita")
	
	if direction:
		velocity.x = direction * SPEED
		# Vira o sprite para a direção que o personagem está andando
		anim.flip_h = direction > 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# 4. Aplicar o movimento
	move_and_slide()

	# 5. Lógica de Animações
	atualizar_animacoes(direction)

# Criei uma função separada para manter o código limpo e organizado
func atualizar_animacoes(direction: float) -> void:
	# Se o personagem NÃO estiver no chão (está no ar)
	if not is_on_floor():
		if velocity.y < 0:
			anim.play("jump") # Subindo
		else:
			anim.play("fall") # Caindo
	
	# Se o personagem estiver no chão
	else:
		if direction != 0:
			anim.play("run")  # Andando/Correndo
		else:
			anim.play("idle") # Parado

func die():
	# 1. Stop normal gravity and player controls
	set_physics_process(false) 
	
	# 2. Turn off the collision box so he falls through the floor!
	$CollisionShape2D.set_deferred("disabled", true)
	
	# 3. Play your flashing "dead" sprite
	$AnimatedSprite2D.play("dead") 
	
	# 4. Create a Tween for the movement (Hop up, then fall down)
	var move_tween = create_tween()
	
	# Hop UP 50 pixels over 0.4 seconds (EASE_OUT makes it slow down at the top)
	move_tween.tween_property(self, "position:y", position.y - 80, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# Fall DOWN 600 pixels off the screen over 1 second (EASE_IN makes it speed up as he falls)
	move_tween.tween_property(self, "position:y", position.y + 600, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	# 5. Create a separate Tween just for the spinning so it happens at the same time
	var spin_tween = create_tween()
	
	# Rotate the crab by a huge amount (15 radians is a few full circles) over 1.4 seconds
	spin_tween.tween_property(self, "rotation", 15.0, 1.4)
	
	# 6. Wait 1.5 seconds for the theatrical death to finish, then restart safely
	await get_tree().create_timer(1.5).timeout
	get_tree().call_deferred("reload_current_scene")
