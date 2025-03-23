extends Node2D
class_name BoxSlot

export(Array, NodePath) var acceptable_boxes = []
export(NodePath) var relay
onready var static_body = $StaticBody2D

func _ready():
	switch_static_coll(false)

func switch_static_coll(enabled):
	static_body.set_collision_layer_bit(0, enabled)
	static_body.set_collision_mask_bit(0, enabled)

func _on_Area2D_body_entered(body:Node):
	print(body)
	if body.is_in_group("Boxes"):
		for i in acceptable_boxes:
			if body == get_node(i):
				body.move_to(position)
				switch_static_coll(true)
				if get_node(relay) != null:
					get_node(relay).enabled = true
