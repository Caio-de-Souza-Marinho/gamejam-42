extends Area2D
class_name StoreItem

@export var common_glow: Color
@export var rare_glow: Color
@export var epic_glow: Color

@onready var sprite: Sprite2D = $Sprite
@onready var glow: Sprite2D = $Glow
@onready var price: RichTextLabel = $Price

var data: ItemData
var can_buy_item: bool

func setup(item_data) -> void:
	data = item_data
	sprite.texture = data.icon
	glow.self_modulate = get_rarity_color()
	price.text = "[code][img=10]Sprites/coin.png[/img][/code] %s" % data.price
	
func get_rarity_color() -> Color:
	match data.rarity:
		"Common":
			return common_glow
		"Rare":
			return rare_glow
		"Epic":
			return epic_glow
	return Color.WHITE

func _on_body_entered(body: Node2D) -> void:
	can_buy_item = true

func _on_body_exited(body: Node2D) -> void:
	can_buy_item = false
