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
		var total := data.damage * (1.0 + Global.upgrade_damage)
		Global.create_damage_text(total, body.global_position)
		body.health_component.take_damage(total)
	
	queue_free()
