extends RigidBody2D

var player_touchable = true

var t = 0.0
var start_trans
var end_trans

func _ready():
	set_physics_process(false)

func move_to(new_position):
	print(new_position)
	t = 0.0
	end_trans = Transform2D(0, new_position)
	start_trans = transform

	set_physics_process(true)
	set_deferred("mode", MODE_STATIC)
	$CollisionShape2D.queue_free()

func _physics_process(delta):
	t += delta

	transform = start_trans.interpolate_with(end_trans, t)
	
	if t >= 1:
		set_physics_process(false)
