extends Area2D

@onready var anim = $Sprite2D # This matches your AnimatedSprite2D node name

func _on_body_entered(body):
	if body.name == "caranguejo":
		# Disable collision so the player doesn't trigger it twice
		$CollisionShape2D.set_deferred("disabled", true)
		
		# Play the grab animation
		anim.play("efeito")
		
		# Wait for the animation to finish
		await anim.animation_finished
		
		# Tell the main level to show the door
		get_parent().show_door()
		
		# Delete the key
		queue_free()
