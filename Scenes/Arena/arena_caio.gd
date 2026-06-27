extends Node2D

# ---------------------- CURSOR --------------------
@export var arena_cursor: Texture2D

func _ready() -> void:
	Cursor.sprite.texture = arena_cursor
