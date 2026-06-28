extends Control

const _FONT_16 := preload("res://Extra/font_16.tres")
const _FONT_48 := preload("res://Extra/font_48.tres")
const _BUTTON_BG := preload("res://Sprites/Interface/Button_Blue.png")

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.0, 0.0, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var title := Label.new()
	title.text = "GAME OVER"
	title.label_settings = _FONT_48
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchor(SIDE_LEFT, 0.0);  title.set_anchor(SIDE_RIGHT, 1.0)
	title.set_anchor(SIDE_TOP, 0.3);   title.set_anchor(SIDE_BOTTOM, 0.3)
	title.offset_bottom = 70.0
	add_child(title)

	var btn := TextureButton.new()
	btn.texture_normal = _BUTTON_BG
	btn.ignore_texture_size = true
	btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	btn.set_anchor(SIDE_LEFT, 0.5);   btn.set_anchor(SIDE_RIGHT, 0.5)
	btn.set_anchor(SIDE_TOP, 0.6);    btn.set_anchor(SIDE_BOTTOM, 0.6)
	btn.offset_left = -80.0;  btn.offset_right = 80.0
	btn.offset_top = 0.0;     btn.offset_bottom = 45.0
	var lbl := Label.new()
	lbl.text = "MENU"
	lbl.label_settings = _FONT_16
	lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(lbl)
	btn.pressed.connect(_on_menu_pressed)
	add_child(btn)

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Global.reset_run()

func _on_menu_pressed() -> void:
	Transition.transition_to("res://Scenes/UI/main_menu.tscn")
