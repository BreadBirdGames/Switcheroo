extends KinematicBody2D
class_name Player

export (int) var speed = 1200
export (int) var jump_speed = -1800
export (int) var gravity = 4000
export (float, 0, 1.0) var friction = 0.1
export (float, 0, 1.0) var acceleration = 0.25
export (int) var max_jump_frames = 10
var coyote_jumping = false
var jump_frames = 0

onready var left_floor_cast = $LeftFloorCast
onready var center_floor_cast = $CenterFloorCast
onready var right_floor_cast = $RightFloorCast

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
	if coyote_jumping:
		if not is_floored():
			jump_frames += 1
			print(jump_frames)
		else:
			if jump_frames < max_jump_frames:
				velocity.y = jump_speed
				coyote_jumping = false
				jump_frames = 0

	get_input()

	if not is_floored():
		velocity.y += gravity * delta

	for i in get_slide_count():
		var collision = get_slide_collision(i)
		var collision_block = collision.get_collider()

		if collision_block.is_in_group("Blocks") and abs(collision_block.get_linear_velocity().x) < BLOCK_MAX_VELOCITY:
			collision_block.apply_central_impulse(collision.get_normal() * -PUSH_FORCE)

	velocity = move_and_slide(velocity, Vector2.UP, false, 4, PI/4, false)

	if Input.is_action_just_pressed("Jump"):
		if is_floored():
			velocity.y = jump_speed
			jump_frames = 0
		else:
			coyote_jumping = true
			jump_frames = 0

func is_floored():
	if center_floor_cast.is_colliding():
		return true
	if left_floor_cast.is_colliding():
		return true
	if right_floor_cast.is_colliding():
		return true
	return false
