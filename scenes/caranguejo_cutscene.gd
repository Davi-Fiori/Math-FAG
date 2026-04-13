extends CharacterBody2D

const SPEED = 130.0
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
