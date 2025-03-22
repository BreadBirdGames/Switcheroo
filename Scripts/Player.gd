extends KinematicBody2D
class_name Player

#Compontents
# onready var blue = $Blue
# onready var blue_collision_shape = $BlueCollisionShape
onready var red = $RedRight
onready var red_collision_shape = $RedCollisionShape

onready var animamtion_players = {
	"red_right": $RedRight/AnimationPlayer,
	#"red_left": $RedLeft/AnimationPlayer,
	#"blue_right": $BlueRight/AnimationPlayer,
	#"blue_left": $BlueLeft/AnimationPlayer,
}
var current_animation_player = "red_right"

# Floor checking
onready var left_floor_cast = $LeftFloorCast
onready var center_floor_cast = $CenterFloorCast
onready var right_floor_cast = $RightFloorCast

# Movement related
export (int) var speed = 1200
export (int) var red_jump_speed = -1000
export (int) var blue_jump_speed = -1800
var jump_speed = red_jump_speed
export (int) var gravity = 4000
export (float, 0, 1.0) var friction = 0.1
export (float, 0, 1.0) var acceleration = 0.25
export (int) var max_jump_frames = 10
var coyote_jumping = false
var jump_frames = 0

var velocity = Vector2.ZERO

# Crawling
var original_scale = Vector2.ONE
var crawling = false

# Box moving
const PUSH_FORCE = 100
const BLOCK_MAX_VELOCITY = 180

var current_box = null
var currently_picked_box = null

# Character switching
enum characters {
	RED,
	BLUE
}

var current_character = characters.RED

# Floor check
func is_floored():
	if center_floor_cast.is_colliding():
		return true
	if left_floor_cast.is_colliding():
		return true
	if right_floor_cast.is_colliding():
		return true
	return false

# Movement
func movement(delta):
	if coyote_jumping:
		if not is_floored():
			jump_frames += 1
		else:
			if jump_frames < max_jump_frames:
				velocity.y = jump_speed
				coyote_jumping = false
				jump_frames = 0

	get_movement_input()

	if not is_floored():
		velocity.y += gravity * delta

func get_movement_input():
	var input = Input.get_vector("Move_Left", "Move_Right", "Move_Left", "Move_Right")
	var dir = input.x
	if dir != 0:
		velocity.x = lerp(velocity.x, dir * speed, acceleration)
		animamtion_players[current_animation_player].play("Run")
	else:
		velocity.x = lerp(velocity.x, 0, friction)
		animamtion_players[current_animation_player].play("RESET")

func jumping():
	if Input.is_action_just_pressed("Jump"):
		if is_floored():
			velocity.y = jump_speed
			jump_frames = 0
		else:
			coyote_jumping = true
			jump_frames = 0

# Crawling
func init_crawl():
	original_scale = scale
	scale = Vector2(1, 0.25)
	crawling = true

func deinit_crawl():
	scale = original_scale
	original_scale = Vector2.ONE
	crawling = false

# Reparenting
func reparent(node, new_parent):
	node.position = new_parent.to_local(node.global_position)
	node.rotation = node.global_rotation - new_parent.global_rotation
	get_parent().remove_child(node)
	new_parent.call_deferred("add_child", node)

# Box moving
func box_check(delta):
	if current_character == characters.RED:
		if Input.is_action_pressed("Activate"):
			if current_box != null:
				if current_box.has_method("red_player_action"):
					current_box.red_player_action()
				else:
					if velocity.x < 0:
						current_box.set_collision_mask_bit(1, false)
						current_box.apply_central_impulse(Vector2(velocity.x,0) * PUSH_FORCE * delta)
		else:
			for i in get_slide_count():
				var collision = get_slide_collision(i)
				var collision_block = collision.get_collider()

				if collision_block.is_in_group("Boxes") and abs(collision_block.get_linear_velocity().x) < BLOCK_MAX_VELOCITY:
					if collision_block.player_touchable:
						collision_block.apply_central_impulse(collision.get_normal() * -PUSH_FORCE)

# Physics tick
func _physics_process(delta):
	movement(delta)

	velocity = move_and_slide(velocity, Vector2.UP, false, 4, PI/4, false)

	box_check(delta)

	jumping()

# Input not consumed by other node
func _unhandled_input(event):
	if event.is_action_pressed("Switch_Character"):
		switch_character()

# Character switching
func switch_to_blue():
	print("Switched to blue")
	current_character = characters.BLUE
	jump_speed = blue_jump_speed
	#blue.show()
	#current_animation_player = "blue_right"
	red.hide()
	red_collision_shape.disabled = true

func switch_to_red():
	print("Switched to red")
	current_character = characters.RED
	jump_speed = red_jump_speed
	current_animation_player = "red_right"
	red.show()
	red_collision_shape.disabled = false
	#blue.hide()

# State changes
func switch_character():
	if current_character == characters.RED:
		switch_to_blue()
	elif current_character == characters.BLUE:
		switch_to_red()
	else:
		print("Invalid current character")

func attempt_crawl():
	if current_character == characters.BLUE:
		init_crawl()

func attempt_un_crawl():
	deinit_crawl()

# Detect rubbing up against block
func _on_BoxDetector_body_entered(body):
	if body.is_in_group("Boxes"):
		current_box = body

func _on_BoxDetector_body_exited(_body):
	current_box = null
