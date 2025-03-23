extends Area2D

func _on_PickupSpear_body_entered(body:Node):
	if body.is_in_group("Player"):
		if body.current_character == body.characters.RED:
			body.spears += 1
			queue_free()