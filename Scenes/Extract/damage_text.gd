extends Control
class_name DamageText

@onready var label: Label = $Label

func setup(value: float) -> void:
	label.text = str(value)
	await get_tree().create_timer(0.1).timeout
	queue_free()
