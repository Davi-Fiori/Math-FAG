extends Area2D

@onready var anim = $Sprite2D # This matches your AnimatedSprite2D node name

func _on_body_entered(body):
	if body.name == "caranguejo":
		# Disable collision so the player doesn't trigger it twice
		$CollisionShape2D.set_deferred("disabled", true)
		
		# --- NEW: Play the Key Pickup Sound ---
		var som_chave = AudioStreamPlayer.new()
		som_chave.stream = preload("res://musicas/chave.ogg")
		
		# We attach it to the parent (the Level) so it survives when the key is deleted!
		get_parent().add_child(som_chave) 
		som_chave.play()
		
		# Tell Godot to clean up the sound node after it finishes playing
		som_chave.finished.connect(som_chave.queue_free)
		# ---------------------------------------
		
		# Play the grab animation
		anim.play("efeito")
		
		# Wait for the animation to finish
		await anim.animation_finished
		
		# Tell the main level to show the door
		get_parent().show_door()
		
		# Delete the key
		queue_free()
