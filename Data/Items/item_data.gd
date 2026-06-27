extends Resource
class_name ItemData

@export var icon: Texture2D
@export var id: String
@export var name: String
@export var value: float
@export var price: float
@export_enum("Common", "Rare", "Epic") var rarity = "Common"
@export_multiline var description: String
