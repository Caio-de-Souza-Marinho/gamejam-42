extends Node2D
class_name EnemySpawner

var enemies: Array[Enemy] = []
var enemies_killed: int
var _generation := 0

func _ready() -> void:
	EventBus.on_enemy_die.connect(_on_enemy_die)

func spawn_enemies(data: LevelData, room: LevelRoom, difficulty: int = 0) -> void:
	if data.enemy_scenes.is_empty(): return

	var my_gen := _generation

	await get_tree().create_timer(0.5).timeout

	if _generation != my_gen or not is_instance_valid(room):
		return

	# +1 mob no min a cada 2 portais, +1 mob no max a cada portal
	var min_mobs := data.min_enemies_per_room + difficulty / 2
	var max_mobs := data.max_enemies_per_room + difficulty
	var amount   := randi_range(min_mobs, max_mobs)
	enemies_killed = amount

	for i in amount:
		var spawn_local_pos := room.get_free_spawn_position()
		var spawn_global_pos := room.to_global(spawn_local_pos)

		var marker = Global.SPAWN_MARKER_SCENE.instantiate()
		marker.global_position = spawn_global_pos
		get_parent().add_child(marker)
		await marker.get_child(0).animation_finished

		if _generation != my_gen or not is_instance_valid(room):
			return

		var random_scene = data.enemy_scenes.pick_random()
		var enemy: Enemy = random_scene.instantiate()

		# Escala stats antes de entrar na árvore (antes do _ready() do enemy)
		var scale := 1.0 + difficulty * 0.15
		enemy.max_health      *= scale
		enemy.collision_damage *= 1.0 + difficulty * 0.10
		enemy.chase_speed      *= 1.0 + difficulty * 0.05

		enemies.append(enemy)
		get_parent().add_child(enemy)
		enemy.global_position = spawn_global_pos

func reset() -> void:
	_generation += 1
	for enemy in enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	enemies.clear()
	enemies_killed = 0

func _on_enemy_die() -> void:
	if enemies_killed <= 0:
		return
	enemies_killed -= 1
	if enemies_killed <= 0:
		EventBus.on_room_cleared.emit()
		enemies.clear()
		enemies_killed = 0
