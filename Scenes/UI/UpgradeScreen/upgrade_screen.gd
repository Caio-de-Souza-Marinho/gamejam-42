extends CanvasLayer
class_name UpgradeScreen

signal confirmed

const _BUTTON_BG := preload("res://Sprites/Interface/Button_Blue.png")
const _SELECTOR  := preload("res://Sprites/Interface/Selector.png")
const _FONT_16   := preload("res://Extra/font_16.tres")
const _FONT_48   := preload("res://Extra/font_48.tres")

# value_pct: percentagem base por upgrade; escala +8% por portal cruzado
const _UPGRADES := [
	{type = "damage",   label = "DANO",      value_pct = 0.15, price_base = 3},
	{type = "hp",       label = "VIDA",       value_pct = 0.20, price_base = 3},
	{type = "speed",    label = "VELOCIDADE", value_pct = 0.10, price_base = 2},
	{type = "cooldown", label = "CADÊNCIA",   value_pct = 0.10, price_base = 4},
]

var _selected: Dictionary = {}
var _cards: Array[TextureButton] = []
var _card_meta: Array[Dictionary] = []   # [{stat_label, price_label, upg}]
var _coins_label: Label

func _ready() -> void:
	layer = 10
	process_mode = PROCESS_MODE_ALWAYS
	_build_ui()
	hide()

# ------------------------------------------------------------------ scaling --

func _scaled_upgrades(portals: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for upg in _UPGRADES:
		var u: Dictionary = upg.duplicate()
		u.value = upg.value_pct * (1.0 + portals * 0.08)
		u.price = upg.price_base + portals
		result.append(u)
	return result

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
	title.set_anchor(SIDE_LEFT, 0.0); title.set_anchor(SIDE_RIGHT, 1.0)
	title.set_anchor(SIDE_TOP, 0.0);  title.set_anchor(SIDE_BOTTOM, 0.0)
	title.offset_top = 20.0; title.offset_bottom = 80.0
	root.add_child(title)

	_coins_label = Label.new()
	_coins_label.label_settings = _FONT_16
	_coins_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_coins_label.set_anchor(SIDE_LEFT, 0.0); _coins_label.set_anchor(SIDE_RIGHT, 1.0)
	_coins_label.set_anchor(SIDE_TOP, 0.0);  _coins_label.set_anchor(SIDE_BOTTOM, 0.0)
	_coins_label.offset_top = 85.0; _coins_label.offset_bottom = 115.0
	root.add_child(_coins_label)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)
	row.set_anchor(SIDE_LEFT, 0.5); row.set_anchor(SIDE_RIGHT, 0.5)
	row.set_anchor(SIDE_TOP, 0.5);  row.set_anchor(SIDE_BOTTOM, 0.5)
	row.offset_left = -200.0; row.offset_right = 200.0
	row.offset_top = -75.0;   row.offset_bottom = 75.0
	root.add_child(row)

	for upg in _UPGRADES:
		var meta := _make_card(upg, row)
		_cards.append(meta.card)
		_card_meta.append(meta)

	var btn := TextureButton.new()
	btn.texture_normal = _BUTTON_BG
	btn.ignore_texture_size = true
	btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	btn.set_anchor(SIDE_LEFT, 0.5);  btn.set_anchor(SIDE_RIGHT, 0.5)
	btn.set_anchor(SIDE_TOP, 1.0);   btn.set_anchor(SIDE_BOTTOM, 1.0)
	btn.offset_left = -80.0; btn.offset_right = 80.0
	btn.offset_top = -75.0;  btn.offset_bottom = -30.0
	var btn_lbl := Label.new()
	btn_lbl.text = "CONTINUAR"
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
	card.custom_minimum_size = Vector2(80, 130)
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

	var sel := TextureRect.new()
	sel.name = "Selector"
	sel.texture = _SELECTOR
	sel.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sel.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sel.set_anchors_preset(Control.PRESET_FULL_RECT)
	sel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sel.hide()
	card.add_child(sel)

	card.pressed.connect(_on_card_pressed.bind(card))
	return {card = card, stat_label = stat_lbl, price_label = price_lbl, upg = {}}

# ------------------------------------------------------------------ public --

func show_screen(portals: int = 0) -> void:
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Cursor.sprite.hide()

	_selected = {}
	_coins_label.text = "Moedas: %d" % int(Global.coins)
	for c in _cards:
		c.get_node("Selector").hide()

	var scaled := _scaled_upgrades(portals)
	for i in _card_meta.size():
		var meta  := _card_meta[i]
		var upg   := scaled[i]
		meta.upg  = upg
		var pct   := roundi(upg.value * 100)
		meta.stat_label.text  = "+%d%%" % pct if upg.type != "cooldown" else "-%d%% recarga" % pct
		meta.price_label.text = "%d moedas" % upg.price

	show()

func hide_screen() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Cursor.sprite.show()
	hide()

# ------------------------------------------------------------------ private --

func _on_card_pressed(card: TextureButton) -> void:
	for c in _cards:
		c.get_node("Selector").hide()
	card.get_node("Selector").show()
	for meta in _card_meta:
		if meta.card == card:
			_selected = meta.upg
			break

func _on_continue_pressed() -> void:
	if not _selected.is_empty() and Global.coins >= _selected.price:
		Global.coins -= _selected.price
		_apply(_selected)
	confirmed.emit()

func _apply(upg: Dictionary) -> void:
	match upg.type:
		"damage":   Global.upgrade_damage   += upg.value
		"hp":       Global.upgrade_hp       += upg.value
		"speed":    Global.upgrade_speed    += upg.value
		"cooldown": Global.upgrade_cooldown += upg.value
