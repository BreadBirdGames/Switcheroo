extends RigidBody2D

var player_touchable = true

var t = 0.0
var start_trans
var end_trans
var moving = false

# func _ready():
	# set_physics_process(false)

func move_to(new_position):
	t = 0.0
	end_trans = Transform2D(0, new_position)
	start_trans = transform

	moving = true
	set_deferred("mode", MODE_STATIC)
	$CollisionShape2D.queue_free()

func _integrate_forces(_state):
	rotation_degrees = 0

func _physics_process(delta):
	if moving:
		t += delta

		transform = start_trans.interpolate_with(end_trans, t)
		
		if t >= 1:
			moving = false
