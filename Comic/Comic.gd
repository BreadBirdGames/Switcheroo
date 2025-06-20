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
	"TickTick": preload("res://Audio/TikTak.ogg"),
	"Boom": preload("res://Audio/Explosion.ogg"),
	"Red_WhatHappened": null,
	"Blue_InYourHead": preload("res://Speech/Blue/Wait am i in your head.ogg"),
	"Red_ConnectedBro": null,
	"Blue_ThinkWeAre": preload("res://Speech/Blue/I think we are.ogg"),
	"Red_SoCool": null,
	"Blue_HowGetOut": preload("res://Speech/Blue/Sure but how do we get me out.ogg"),
	"MagicPoof": preload("res://Audio/Magic Poof.ogg"),
	"Old_Hello": null,
	"Blue_HaveAnswer": preload("res://Speech/Blue/If you have the answer please do tell.ogg"),
	"Old_BackInMy": null,
	"Red_And": null,
	"Old_HappenTo": null,
	"Red_Yes": null,
	"Old_ListenClose": null,
	"Blue_NotACastle": preload("res://Speech/Blue/Really not a castle and a dragon.ogg"),
	"Old_OverThere": null,
	"Blue_NoTime": preload("res://Speech/Blue/no time to waste.ogg")
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

		match index:
			0:
				$PageTimer1.start()
			1: # Bomb 1
				$PageTimer2.start()
			2: # Red concern bomb and dialogue start
				DialogueInterface.show_dialogue("ComicSubtitles", comic)

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

			$PageTimer1.start()
		else:
			if index == 0:
				$PageTimer1.stop()
			elif index == 1:
				$PageTimer2.stop()
			
			comic_move_page()

func _on_PageTimer1_timeout():
	comic_move_page()

func _on_PageTimer2_timeout():
	comic_move_page()

func _on_AudioStreamPlayer_finished():
	$AudioStreamPlayer.stream = null
	$AudioStreamPlayer.stop()

	if DialogueInterface.balloon.dialogue_line != null:
		DialogueInterface.balloon.next(DialogueInterface.balloon.dialogue_line.next_id)

func load_into_game():
	get_tree().change_scene("res://Levels/Level1.tscn")
