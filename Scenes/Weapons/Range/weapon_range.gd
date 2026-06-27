extends Weapon
class_name WeaponRange

@onready var sprite: Sprite2D = %Sprite2D

var direction: Vector2

func _process(delta: float) -> void:
	rotate_weapon()

func use_weapon() -> void:
	pass
	
func rotate_weapon() -> void:
	direction = get_global_mouse_position() - global_position
	sprite.flip_v = direction.x < 0
