extends Node2D

onready var tween = $Tween
var original_blue_position
var original_red_position

func _ready():
	$Control/BluePanel.hide()
	$Control/RedPanel.hide()
	original_blue_position = $Control/BlueButtonTexture.rect_position
	original_red_position = $Control/RedButtonTexture.rect_position
	$Control.hide()

func reveal():
	print("uwu")
	$Control.show()
	$Player.queue_free()

func _on_BlueButton_pressed():
	get_tree().quit()

func _on_RedButton_pressed():
	get_tree().quit()

func _on_BlueButton_mouse_entered():
	$Control/BluePanel.show()
	tween.interpolate_property($Control/BlueButtonTexture, "rect_position",
			$Control/BlueButtonTexture.rect_position, $Control/BlueButtonTexture.rect_position + Vector2(0,80), 1,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func _on_BlueButton_mouse_exited():
	$Control/BluePanel.hide()
	tween.interpolate_property($Control/BlueButtonTexture, "rect_position",
			$Control/BlueButtonTexture.rect_position, original_blue_position, 1,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func _on_RedButton_mouse_entered():
	$Control/RedPanel.show()
	tween.interpolate_property($Control/RedButtonTexture, "rect_position",
			$Control/RedButtonTexture.rect_position, $Control/RedButtonTexture.rect_position + Vector2(0,80), 1,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func _on_RedButton_mouse_exited():
	$Control/RedPanel.hide()
	tween.interpolate_property($Control/RedButtonTexture, "rect_position",
			$Control/RedButtonTexture.rect_position, original_red_position, 1,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
