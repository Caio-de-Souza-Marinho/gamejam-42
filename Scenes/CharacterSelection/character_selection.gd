extends Control
class_name CharacterSelection

const PLAYER_CARD_SCENE = preload("uid://bdxtwkeuh8oa6")
const WEAPON_CARD_SCENE = preload("uid://lo1pyqpcogwy")

@export var selection_cursor: Texture2D
@export var players: Array[PlayerData]
@export var weapons: Array[WeaponData]

@onready var player_container: HBoxContainer = $PlayerContainer
@onready var weapon_container: HBoxContainer = $WeaponContainer

func _ready() -> void:
	Cursor.sprite.texture = selection_cursor
	load_selection_items()

func load_selection_items() -> void:
	for node in player_container.get_children():
		node.queue_free()
	for node in weapon_container.get_children():
		node.queue_free()

	for data: PlayerData in players:
		var card: PlayerCard = PLAYER_CARD_SCENE.instantiate()
		player_container.add_child(card)
		card.set_data(data)
		
	for data: WeaponData in weapons:
		var card: WeaponCard = WEAPON_CARD_SCENE.instantiate()
		weapon_container.add_child(card)
		card.set_data(data)
