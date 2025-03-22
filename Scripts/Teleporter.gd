extends Area2D
class_name Teleporter

export(NodePath) var connected_portal = null
export(Vector2) var spit_out_offset = Vector2.ZERO
export(bool) var only_player = true

func _ready():
	if connected_portal == null:
		print("missing connected port to ", self)

func _on_Teleporter_body_entered(body:Node):
	if body.is_in_group("Player"):
		body.position = get_node(connected_portal).position + spit_out_offset
	
	if not only_player:
		if not body.is_in_group("Player"):
			body.position = get_node(connected_portal).position + spit_out_offset
