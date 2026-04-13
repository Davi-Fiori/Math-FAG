extends Node2D

# This creates a slider in the Inspector so you can make some clouds fast and some slow!
@export var speed: float = 50.0 

func _process(delta):
	# 1. Move the cloud to the left a little bit every single frame
	position.x -= speed * delta
	
	# 2. Check if the cloud has moved completely off the left side of the screen
	# (We use -200 so it waits until the whole image is hidden before teleporting)
	if position.x < -200:
		
		# 3. Teleport it to the far right side, just outside the visible screen!
		# get_viewport_rect().size.x automatically gets the width of your game window
		position.x = get_viewport_rect().size.x + 200
