extends Node

var save_path = "user://save.json"

const EXPLOSION_EFFECT_SCENE = preload("res://Scenes/Effects/explosion_effect.tscn")
const DAMAGE_TEXT_SCENE = preload("res://Scenes/Extract/damage_text.tscn")

const SPAWN_MARKER_SCENE = preload("res://Scenes/Effects/spawn_marker.tscn")
const DEAD_PARTICLE_SCENE = preload("uid://dhg2agreu5c6d")

const PORTAL_SCENE = preload("res://Scenes/Extract/portal.tscn")



var settings: Dictionary = {
	"music": true,
	"sfx": true,
	"fullscreen": true
}

var all_players: Dictionary[String, PackedScene] = {
	"Dog": preload("uid://dmjkb2av14sfd"),
	"Bunny": preload("uid://dxp70f0abog78")
}

var player_ref: Player

var all_weapons: Dictionary[String, PackedScene] = {
	"Pistol": preload("uid://dq2qd67tnk5p8"),
	"Uzi": preload("uid://ddsebnxllynxw")
}

var selected_player: PlayerData
var selected_weapon: WeaponData

func _ready() -> void:
	load_data()

func get_player() -> PackedScene:
	return all_players[selected_player.id]
	
func get_weapon() -> PackedScene:
	return all_weapons[selected_weapon.weapon_name]

func create_explosion(pos: Vector2) -> void:
	var explosion: Node2D =  EXPLOSION_EFFECT_SCENE.instantiate()
	explosion.global_position = pos
	get_tree().root.add_child(explosion)
	
func create_damage_text(value: float, pos: Vector2) -> void:
	var damage: DamageText = DAMAGE_TEXT_SCENE.instantiate()
	get_parent().add_child(damage)
	var random_pos = randf_range(0, TAU)
	damage.global_position = pos + Vector2.RIGHT.rotated(random_pos) * 20
	damage.setup(value)
	

func save_data() -> void:
	var save = settings.duplicate()
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	var json_string = JSON.stringify(save)
	file.store_string(json_string)
	file.close()
	
func load_data() -> void:
	if not FileAccess.file_exists(save_path):
		return
	var file = FileAccess.open(save_path, FileAccess.READ)
	var json = file.get_as_text()
	var data = JSON.parse_string(json)
	file.close()
	settings = data

func create_dead_particle(texture: Texture2D, pos: Vector2) -> void:
	var particle = DEAD_PARTICLE_SCENE.instantiate() as GPUParticles2D
	get_tree().root.add_child(particle)
	particle.global_position = pos
	particle.texture = texture
