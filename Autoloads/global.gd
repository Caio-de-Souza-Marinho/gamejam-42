extends Node

var save_path = "user://save.json"

var settings: Dictionary = {
	"music": true,
	"sfx": true,
	"fullscreen": true
}

var all_players: Dictionary[String, PackedScene] = {
	"Dog": preload("uid://dmjkb2av14sfd"),
	"Bunny": preload("uid://dxp70f0abog78")
}

var all_weapons: Dictionary[String, PackedScene] = {
	"Pistol": preload("uid://dq2qd67tnk5p8"),
	"Uzi": preload("uid://ddsebnxllynxw")
}

var selected_player: PlayerData
var selected_weapon: WeaponData

func get_player() -> PackedScene:
	return all_players[selected_player.id]
	
func get_weapon() -> PackedScene:
	return all_weapons[selected_weapon.weapon_name]

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
