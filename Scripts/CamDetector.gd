extends Area2D

export(NodePath) var camera_path
export(Vector2) var camera_position
export(Vector2) var camera_zoom

onready var tween = $Tween
onready var camera = get_node(camera_path)

func _on_CamDetector_body_entered(body:Node):
	if body.is_in_group("Player"):
		tween.interpolate_property(camera, "position",
				camera.position, camera_position, 1,
				Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.interpolate_property(camera, "zoom",
				camera.zoom, camera_zoom, 1,
				Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
