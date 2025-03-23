extends StaticBody2D

var hit = false
var angle

func _physics_process(delta):
	if not hit:
		position += Vector2.RIGHT
		print(position)