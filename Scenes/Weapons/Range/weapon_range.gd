extends Weapon
class_name WeaponRange

@onready var sprite: Sprite2D = %Sprite2D
@onready var fire_pos: Marker2D = %FirePos
var direction: Vector2

func setup(data: WeaponData) -> void:
	self.data = data

func _process(delta: float) -> void:
	rotate_weapon()

func use_weapon() -> void:
	var bullet: Bullet = data.bullet_scene.instantiate()
	bullet.setup(data)
	bullet.global_position = fire_pos.global_position
	bullet.global_rotation = pivot.global_rotation + deg_to_rad(randf_range(-data.spread, data.spread))
	get_tree().root.add_child(bullet)
	
func rotate_weapon() -> void:
	direction = get_global_mouse_position() - global_position
	sprite.flip_v = direction.x < 0
