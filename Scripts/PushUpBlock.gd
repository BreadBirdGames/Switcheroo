extends StaticBody2D

export(Vector2) var end_position
export(NodePath) var crawl_space
export(float) var speed_mult = 1.0
var start_position
var moving = false
var t = 0.0
var player_touchable = false

func red_player_action():
	moving = true
	start_position = position

func _physics_process(delta):
	if moving:
		t += delta * speed_mult

		position = start_position.linear_interpolate(start_position + end_position, t)
		
		if t >= 1:
			moving = false
			get_node(crawl_space).enabled = true
