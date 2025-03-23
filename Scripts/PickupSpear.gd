extends Area2D

func _on_PickupSpear_body_entered(body:Node):
	if body.is_in_group("Player"):
		body.spears += 1
		print(body.spears)
		queue_free()