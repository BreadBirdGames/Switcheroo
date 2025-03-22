extends Area2D

export(PackedScene) var load_scene

func _on_LevelLoader_body_entered(body:Node):
	if body.is_in_group("Player"):
		if load_scene != null:
			var resource = preload("res://Dialogue/test.tres")
			DialogueInterface.show_dialogue("this_is_a_node_title", resource)

			get_tree().change_scene_to(load_scene)
		else:
			get_tree().reload_current_scene()