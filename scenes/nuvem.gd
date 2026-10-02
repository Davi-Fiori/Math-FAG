extends Node2D

@export var speed: float = 40.0
@export var start_right_x: float = 260.0
@export var end_left_x: float = -164.0 # The exact left edge of your level

func _process(delta: float) -> void:
	position.x -= speed * delta

	# Manually reset the cloud once it passes the invisible boundary
	if position.x < end_left_x:
		position.x = start_right_x
