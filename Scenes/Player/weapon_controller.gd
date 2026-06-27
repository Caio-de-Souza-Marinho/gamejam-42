extends Node2D
class_name WeaponController

var current_weapon: Weapon
var target_pos: Vector2

func _process(delta: float) -> void:
	target_pos = get_global_mouse_position()
	rotate_weapon()

func rotate_weapon() -> void:
	if not current_weapon:
		return
		
	current_weapon.pivot.look_at(target_pos)
