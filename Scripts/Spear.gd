extends StaticBody2D

export(float) var speed_mult = 1.0
var hit = false
var angle

func _physics_process(_delta):
	if not hit:
		position += Vector2(1, 0).rotated(rotation) * speed_mult

func _on_Area2D_body_entered(_body):
	hit = true
