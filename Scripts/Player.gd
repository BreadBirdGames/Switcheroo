extends KinematicBody2D
class_name Player

#Compontents
onready var blue_left = $BlueLeft
onready var blue_right = $BlueRight
onready var red_right = $RedRight
onready var red_left = $RedLeft

onready var collision_shape = $CollisionShape
onready var crawl_collision_shape = $CollisionShape
onready var direction_object = $DirectionObject
onready var arrow_cooldown = $ArrowCooldown

# Floor checking
onready var left_floor_cast = $LeftFloorCast
onready var center_floor_cast = $CenterFloorCast
onready var right_floor_cast = $RightFloorCast

# Movement related
export (int) var speed = 1200
export (int) var red_jump_speed = -1000
export (int) var blue_jump_speed = -1800
var jump_speed = 0
export (int) var gravity = 4000
export (float, 0, 1.0) var friction = 0.1
export (float, 0, 1.0) var acceleration = 0.25
export (int) var max_jump_frames = 10
export(PackedScene) var spear
var coyote_jumping = false
var jump_frames = 0

var velocity = Vector2.ZERO

# Crawling
var original_scale = Vector2.ONE
var crawling = false
var can_crawl = false

# Box moving
const PUSH_FORCE = 100
const BLOCK_MAX_VELOCITY = 180

var current_box = null
var currently_picked_box = null

# Character switching
enum characters {
	RED,
	BLUE,
	NONE
}

var current_character = characters.NONE

# Animation
onready var animation_players = {
	"red_right": $RedRight/AnimationPlayer,
	"red_left": $RedLeft/AnimationPlayer,
	"blue_right": $BlueRight/AnimationPlayer,
	"blue_left": $BlueLeft/AnimationPlayer,
}

# Misc
var spears = 0

# Directions
enum directions {
	LEFT,
	RIGHT
}
var direction = directions.RIGHT setget set_direction

func set_direction(val):
	if val == directions.RIGHT:
		$BoxDetector.position.x = 25
		if current_character == characters.RED:
			red_left.hide()
			red_right.show()
		else:
			blue_left.hide()
			blue_right.show()
	elif val == directions.LEFT:
		$BoxDetector.position.x = -25
		if current_character == characters.RED:
			red_right.hide()
			red_left.show()
		else:
			blue_right.hide()
			blue_left.show()

	direction = val

# get current animation player
func current_anim_player():
	var value = ""

	if current_character == characters.RED:
		value += "red_"
	elif current_character == characters.BLUE:
		value += "blue_"

	if direction == directions.LEFT:
		value += "left"
	elif direction == directions.RIGHT:
		value += "right"

	return value

# Floor check
func is_floored():
	if center_floor_cast.is_colliding():
		return true
	if left_floor_cast.is_colliding():
		return true
	if right_floor_cast.is_colliding():
		return true
	return false

# Start function
func _ready():
	switch_to_red()

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

		if velocity.x > 0:
			set_direction(directions.RIGHT)
		elif velocity.x < 0:
			set_direction(directions.LEFT)

		if current_character == characters.BLUE && crawling:
			animation_players[current_anim_player()].play("Crawl")
		else:
			animation_players[current_anim_player()].play("Run")
	else:
		velocity.x = lerp(velocity.x, 0, friction)

		if current_character == characters.BLUE && crawling:
			animation_players[current_anim_player()].stop(false)
		else:
			animation_players[current_anim_player()].play("RESET")

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
	crawling = true
	crawl_collision_shape.set_deferred("disabled", false)
	collision_shape.set_deferred("disabled", true)

func deinit_crawl():
	crawling = false
	crawl_collision_shape.set_deferred("disabled", true)
	collision_shape.set_deferred("disabled", false)

# Reparenting
func reparent(node, new_parent):
	node.position = new_parent.to_local(node.global_position)
	node.rotation = node.global_rotation - new_parent.global_rotation
	get_parent().remove_child(node)
	new_parent.call_deferred("add_child", node)

# Box moving
func box_check():
	if current_character == characters.RED:
		if Input.is_action_pressed("Activate"):
			if current_box != null:
				if current_box.has_method("red_player_action"):
					current_box.red_player_action()
		else:
			for i in get_slide_count():
				var collision = get_slide_collision(i)
				var collision_block = collision.get_collider()

				if collision_block.is_in_group("Boxes"):
					if collision_block.player_touchable:
						if abs(collision_block.get_linear_velocity().x) < BLOCK_MAX_VELOCITY:
							collision_block.apply_central_impulse(Vector2(collision.get_normal().x, 0) * -PUSH_FORCE)

# Physics tick
func _physics_process(delta):
	movement(delta)

	velocity = move_and_slide(velocity, Vector2.UP, false, 4, PI/2, false)

	box_check()

	jumping()

# Input not consumed by other node
func _unhandled_input(event):
	if event.is_action_pressed("Switch_Character"):
		switch_character()
	
	if event is InputEventMouseMotion:
		var mouse_pos = get_viewport().get_mouse_position() - get_global_transform_with_canvas().get_origin()
		
		direction_object.position = mouse_pos.normalized()
	elif event is InputEventMouseButton:
		if event.button_index == 1 && event.pressed:
			if current_character == characters.RED && spears > 0 && arrow_cooldown.is_stopped():
				var mouse_pos = get_viewport().get_mouse_position() - get_global_transform_with_canvas().get_origin()
		
				direction_object.position = mouse_pos.normalized()

				var new_spear = spear.instance()
				get_parent().add_child(new_spear)
				new_spear.position = position + direction_object.position
				new_spear.rotation_degrees = rad2deg((direction_object.position * Vector2(1,-1)).angle_to(Vector2.RIGHT))
				
				spears -= 1
				arrow_cooldown.start()

# Character switching
func switch_to_blue():
	print("Switched to blue")
	current_character = characters.BLUE
	jump_speed = blue_jump_speed
	blue_left.show()
	blue_right.show()
	red_left.hide()
	red_right.hide()
	set_direction(direction)

	if can_crawl:
		init_crawl()

func switch_to_red():
	print("Switched to red")
	current_character = characters.RED
	jump_speed = red_jump_speed
	red_left.show()
	red_right.show()
	blue_left.hide()
	blue_right.hide()
	set_direction(direction)

# State changes
func switch_character():
	if current_character == characters.RED:
		switch_to_blue()
	elif current_character == characters.BLUE:
		switch_to_red()
	else:
		print("Invalid current character")

func attempt_crawl():
	can_crawl = true
	if current_character == characters.BLUE:
		init_crawl()

func attempt_un_crawl():
	can_crawl = false
	deinit_crawl()

# Detect rubbing up against block
func _on_BoxDetector_body_entered(body):
	if body.is_in_group("Boxes"):
		current_box = body

func _on_BoxDetector_body_exited(_body):
	current_box = null
