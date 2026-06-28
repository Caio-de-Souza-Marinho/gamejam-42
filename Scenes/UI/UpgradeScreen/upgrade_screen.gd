extends CanvasLayer
class_name UpgradeScreen

signal confirmed

const _BUTTON_BG := preload("res://Sprites/Interface/Button_Blue.png")
const _SELECTOR  := preload("res://Sprites/Interface/Selector.png")
const _FONT_16   := preload("res://Extra/font_16.tres")
const _FONT_48   := preload("res://Extra/font_48.tres")

# value_pct: percentagem base; escala +8% por portal cruzado
const _UPGRADES := [
	{type = "damage",   label = "DAMAGE",    value_pct = 0.30, price_base = 3},
	{type = "hp",       label = "HEALTH",    value_pct = 0.40, price_base = 3},
	{type = "speed",    label = "SPEED",     value_pct = 0.15, price_base = 2},
	{type = "cooldown", label = "FIRE RATE", value_pct = 0.20, price_base = 4},
]

var _coins_label: Label
var _card_meta: Array[Dictionary] = []   # [{card, stat_label, price_label, upg}]
var _portals: int = 0
var _purchases: int = 0                  # compras feitas nesta fase
var _frozen_player: Player               # guarda o player para restaurar depois

func _ready() -> void:
	layer = 10
	process_mode = PROCESS_MODE_ALWAYS
	_build_ui()
	hide()

# ------------------------------------------------------------------ helpers --

func _value(upg: Dictionary) -> float:
	return upg.value_pct * (1.0 + _portals * 0.08)

func _price(upg: Dictionary) -> int:
	# cada compra nesta fase encarece todos os upgrades em 2 moedas
	return upg.price_base + _portals + _purchases * 2

# ------------------------------------------------------------------ build UI --

func _build_ui() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var overlay := ColorRect.new()
	overlay.color = Color(0.05, 0.05, 0.1, 0.92)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(overlay)

	var title := Label.new()
	title.text = "UPGRADE"
	title.label_settings = _FONT_48
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchor(SIDE_LEFT, 0.0);  title.set_anchor(SIDE_RIGHT, 1.0)
	title.set_anchor(SIDE_TOP, 0.0);   title.set_anchor(SIDE_BOTTOM, 0.0)
	title.offset_top = 20.0;           title.offset_bottom = 80.0
	root.add_child(title)

	_coins_label = Label.new()
	_coins_label.label_settings = _FONT_16
	_coins_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_coins_label.set_anchor(SIDE_LEFT, 0.0);  _coins_label.set_anchor(SIDE_RIGHT, 1.0)
	_coins_label.set_anchor(SIDE_TOP, 0.0);   _coins_label.set_anchor(SIDE_BOTTOM, 0.0)
	_coins_label.offset_top = 85.0;           _coins_label.offset_bottom = 115.0
	root.add_child(_coins_label)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)
	row.set_anchor(SIDE_LEFT, 0.5);  row.set_anchor(SIDE_RIGHT, 0.5)
	row.set_anchor(SIDE_TOP, 0.5);   row.set_anchor(SIDE_BOTTOM, 0.5)
	row.offset_left = -250.0;        row.offset_right = 250.0
	row.offset_top = -80.0;          row.offset_bottom = 80.0
	root.add_child(row)

	for upg in _UPGRADES:
		_card_meta.append(_make_card(upg, row))

	var btn := TextureButton.new()
	btn.texture_normal = _BUTTON_BG
	btn.ignore_texture_size = true
	btn.stretch_mode = TextureButton.STRETCH_SCALE
	btn.set_anchor(SIDE_LEFT, 0.5);   btn.set_anchor(SIDE_RIGHT, 0.5)
	btn.set_anchor(SIDE_TOP, 1.0);    btn.set_anchor(SIDE_BOTTOM, 1.0)
	btn.offset_left = -120.0;  btn.offset_right = 120.0
	btn.offset_top = -75.0;    btn.offset_bottom = -25.0
	var btn_lbl := Label.new()
	btn_lbl.text = "CONTINUE"
	btn_lbl.label_settings = _FONT_16
	btn_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	btn_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	btn_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(btn_lbl)
	btn.pressed.connect(_on_continue_pressed)
	root.add_child(btn)

func _make_card(upg: Dictionary, parent: Node) -> Dictionary:
	var card := TextureButton.new()
	card.custom_minimum_size = Vector2(110, 140)
	card.texture_normal = _BUTTON_BG
	card.ignore_texture_size = true
	card.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	parent.add_child(card)

	var col := VBoxContainer.new()
	col.set_anchors_preset(Control.PRESET_FULL_RECT)
	col.add_theme_constant_override("separation", 6)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(col)

	var name_lbl := Label.new()
	name_lbl.text = upg.label
	name_lbl.label_settings = _FONT_16
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(name_lbl)

	var stat_lbl := Label.new()
	stat_lbl.label_settings = _FONT_16
	stat_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stat_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(stat_lbl)

	var price_lbl := Label.new()
	price_lbl.label_settings = _FONT_16
	price_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	price_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(price_lbl)

	card.pressed.connect(_on_card_pressed.bind(card))
	return {card = card, stat_label = stat_lbl, price_label = price_lbl, upg = upg}

# ------------------------------------------------------------------ public --

func show_screen(portals: int = 0) -> void:
	_portals = portals
	_purchases = 0
	# Desabilita o player em vez de pausar a árvore inteira.
	# Pausar a árvore impede corrotinas em nós pausados de resumir via sinal,
	# o que quebraria o "await upgrade_screen.confirmed" na arena.
	_frozen_player = Global.player_ref
	if is_instance_valid(_frozen_player):
		_frozen_player.process_mode = PROCESS_MODE_DISABLED
	Global.player_ref = null  # inimigos param de perseguir
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Cursor.sprite.hide()
	_refresh()
	show()

func hide_screen() -> void:
	if is_instance_valid(_frozen_player):
		_frozen_player.process_mode = PROCESS_MODE_INHERIT
	Global.player_ref = _frozen_player
	_frozen_player = null
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Cursor.sprite.show()
	hide()

# ------------------------------------------------------------------ private --

func _refresh() -> void:
	_coins_label.text = "Coins: %d" % int(Global.coins)
	for meta in _card_meta:
		var upg: Dictionary = meta.upg
		var pct: int        = roundi(_value(upg) * 100)
		var price: int      = _price(upg)
		meta.stat_label.text  = "-%d%% reload" % pct if upg.type == "cooldown" else "+%d%%" % pct
		meta.price_label.text = "%d coins" % price
		meta.card.modulate    = Color.WHITE if Global.coins >= price else Color(0.45, 0.45, 0.45, 1.0)

func _on_card_pressed(card: TextureButton) -> void:
	var meta: Dictionary = {}
	for m in _card_meta:
		if m.card == card:
			meta = m
			break
	if meta.is_empty():
		return

	var upg: Dictionary = meta.upg
	var price: int      = _price(upg)
	if Global.coins < price:
		return

	Global.coins -= price
	_purchases += 1

	match upg.type:
		"damage":   Global.upgrade_damage   += _value(upg)
		"hp":       Global.upgrade_hp       += _value(upg)
		"speed":    Global.upgrade_speed    += _value(upg)
		"cooldown": Global.upgrade_cooldown += _value(upg)

	_refresh()

func _on_continue_pressed() -> void:
	confirmed.emit()
