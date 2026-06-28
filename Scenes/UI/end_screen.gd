extends Control

@export var menu_cursor: Texture2D

@onready var ui_sound: AudioStreamPlayer = $UISound
@onready var hover_sound: AudioStreamPlayer = $HoverSound

func _ready() -> void:
	Cursor.sprite.texture = menu_cursor
	Global.reset_run()

func _on_play_button_pressed() -> void:
	ui_sound.play()
	Transition.transition_to("res://Scenes/CharacterSelection/character_selection.tscn")

func _on_quit_button_pressed() -> void:
	ui_sound.play()
	Global.save_data()
	get_tree().quit()

func _on_button_mouse_entered() -> void:
	hover_sound.play()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		Global.save_data()
