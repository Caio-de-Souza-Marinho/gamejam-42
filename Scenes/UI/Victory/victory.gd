extends Control

const _FONT_16    := preload("res://Extra/font_16.tres")
const _FONT_48    := preload("res://Extra/font_48.tres")
const _TILEMAP    := preload("res://Sprites/Interface/Tilemap/tilemap_packed.png")
const _CLICK_SND  := preload("res://Sounds/select-a.ogg")
const _HOVER_SND  := preload("res://Sounds/button_hover.wav")
const _BACKGROUND := preload("res://Scenes/UI/background.tscn")

var _click_player: AudioStreamPlayer

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	add_child(_BACKGROUND.instantiate())

	var title := Label.new()
	title.text = "VOCÊ VENCEU!"
	title.label_settings = _FONT_48
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchor(SIDE_LEFT, 0.0);  title.set_anchor(SIDE_RIGHT, 1.0)
	title.set_anchor(SIDE_TOP, 0.3);   title.set_anchor(SIDE_BOTTOM, 0.3)
	title.offset_bottom = 70.0
	add_child(title)

	_click_player = AudioStreamPlayer.new()
	_click_player.stream = _CLICK_SND
	_click_player.bus = &"SFX"
	add_child(_click_player)

	_add_button("MENU", 0.58, _on_menu_pressed)

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Cursor.sprite.hide()
	Global.reset_run()

func _make_btn_tex() -> AtlasTexture:
	var t := AtlasTexture.new()
	t.atlas = _TILEMAP
	t.region = Rect2(112, 48, 49, 16)
	return t

func _add_button(label_text: String, v_anchor: float, callback: Callable) -> void:
	var hover := AudioStreamPlayer.new()
	hover.stream = _HOVER_SND
	hover.bus = &"SFX"
	add_child(hover)

	var btn := TextureButton.new()
	btn.texture_normal = _make_btn_tex()
	btn.ignore_texture_size = true
	btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	btn.set_anchor(SIDE_LEFT, 0.5);   btn.set_anchor(SIDE_RIGHT, 0.5)
	btn.set_anchor(SIDE_TOP, v_anchor); btn.set_anchor(SIDE_BOTTOM, v_anchor)
	btn.offset_left = -94.5; btn.offset_right = 94.5
	btn.offset_top  = -24.0; btn.offset_bottom = 24.0

	var lbl := Label.new()
	lbl.text = label_text
	lbl.label_settings = _FONT_16
	lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(lbl)

	btn.mouse_entered.connect(hover.play)
	btn.pressed.connect(callback)
	add_child(btn)

func _on_menu_pressed() -> void:
	_click_player.play()
	await _click_player.finished
	Transition.transition_to("res://Scenes/UI/main_menu.tscn")
