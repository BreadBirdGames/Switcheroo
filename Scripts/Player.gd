extends KinematicBody2D
class_name Player

export (int) var speed = 1200
export (int) var jump_speed = -1800
export (int) var gravity = 4000
export (float, 0, 1.0) var friction = 0.1
export (float, 0, 1.0) var acceleration = 0.25

const PUSH_FORCE = 100
const BLOCK_MAX_VELOCITY = 180

var velocity = Vector2.ZERO

func get_input():
	var input = Input.get_vector("Move_Left", "Move_Right", "Move_Left", "Move_Right")
	var dir = input.x
	if dir != 0:
		velocity.x = lerp(velocity.x, dir * speed, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0, friction)


func _physics_process(delta):
	get_input()
	if not is_on_floor():
		velocity.y += gravity * delta

	for i in get_slide_count():
		var collision = get_slide_collision(i)
		var collision_block = collision.get_collider()

		if collision_block.is_in_group("Blocks") and abs(collision_block.get_linear_velocity().x) < BLOCK_MAX_VELOCITY:
			collision_block.apply_central_impulse(collision.get_normal() * -PUSH_FORCE)

	velocity = move_and_slide(velocity, Vector2.UP, false, 4, PI/4, false)

	if Input.is_action_just_pressed("Jump") and is_on_floor():
			velocity.y = jump_speed
