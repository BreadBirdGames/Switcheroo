extends Node2D

onready var sound_player = $AudioStreamPlayer
onready var camera_tween = $CameraTween

var comic = preload("res://Dialogue/IntroComic.tres")

var activated_comic = false
var index = 0
var y_index = 0
var offset = Vector2(180,100)
var zoom = Vector2(0.4, 0.4)
var x_positions = [
	0,
	325
]
var y_positions = [
	0,
	200,
	390,
	580,
	765,
	950,
	1145
]

var audio_files = {
	"Red_BlueButton": null,
	"Blue_CantBeSure": preload("res://Speech/Blue/We cant be sure of that.ogg"),
}

func comic_play_sound(sound):
	if audio_files.has(sound):
		var sound_file = audio_files[sound]
		
		sound_player.stream = sound_file
		sound_player.play()

func comic_move_page():
	if index != 13:
		var x
		var y

		index += 1

		# Is odd
		if index % 2 == 1:
			x = x_positions[1]
		else:
			x = x_positions[0]
			y_index += 1
		
		y = y_positions[y_index]

		var new_pos = Vector2(x,y)

		camera_tween.interpolate_property($Camera2D, "position",
			$Camera2D.position, new_pos, 1,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		camera_tween.start()

			
		

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		if not activated_comic:
			activated_comic = true
			
			camera_tween.interpolate_property($Camera2D, "offset",
					Vector2(345, 200), offset, 1,
					Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			camera_tween.interpolate_property($Camera2D, "zoom",
					Vector2(0.7, 0.7), zoom, 1,
					Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			camera_tween.start()

			# $PageTimer1.start()

			#var comic = preload("res://Dialogue/IntroComic.tres")
			#DialogueInterface.show_dialogue("ComicSubtitles", comic)
		else:
			comic_move_page()

# func _on_PageTimer1_timeout():
# 	$PageTimer2.start()
# 	comic_move_page()

# func _on_PageTimer2_timeout():
# 	DialogueInterface.show_dialogue("ComicSubtitles", comic)
