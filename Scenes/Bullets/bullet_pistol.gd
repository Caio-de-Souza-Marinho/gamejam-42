extends Area2D
class_name Bullet

var data: WeaponData

func setup(data: WeaponData) -> void:
	self.data = data

func _process(delta: float) -> void:
	if not data: return
	move_local_x(data.bullet_speed * delta)

func _on_body_entered(body: Node2D) -> void:
	Global.create_explosion(global_position)
	
	if body is Enemy or body is Player:
		Global.create_damage_text(data.damage, body.global_position)
		body.health_component.take_damage(data.damage)
	
	queue_free()
