extends Node2D

onready var sound_player = $AudioStreamPlayer

var activated_comic = false
var index = 0

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
	if index != 5:
		index += 1
		$AnimationPlayer.play("Tile" + str(index))

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		if not activated_comic:
			activated_comic = true
			var comic = preload("res://Dialogue/IntroComic.tres")
			DialogueInterface.show_dialogue("ComicSubtitles", comic)
