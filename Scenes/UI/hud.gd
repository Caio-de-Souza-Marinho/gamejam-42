extends CanvasLayer
class_name HUD

@onready var health_bar: TextureProgressBar = find_child("HealthBar", true, false)

var _glitch_mat: ShaderMaterial
var _glitch_overlay: ColorRect

func _ready() -> void:
	if health_bar == null:
		push_error("HealthBar não encontrado no HUD")
	_setup_glitch_overlay()
	EventBus.on_player_health_updated.connect(_on_player_health_updated)

func _setup_glitch_overlay() -> void:
	_glitch_overlay = ColorRect.new()
	_glitch_overlay.size = get_viewport().get_visible_rect().size
	_glitch_overlay.position = Vector2.ZERO
	_glitch_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_glitch_overlay.visible = false  # esconde até o primeiro dano para evitar tela branca

	_glitch_mat = ShaderMaterial.new()
	_glitch_mat.shader = load("res://Shaders/glitch_screen.gdshader")
	_glitch_mat.set_shader_parameter("intensity", 0.0)
	_glitch_overlay.material = _glitch_mat

	add_child(_glitch_overlay)
	move_child(_glitch_overlay, 0)  # renderiza atrás da health bar

func _on_player_health_updated(current: float, max: float) -> void:
	if health_bar:
		health_bar.value = current / max
	_update_glitch(current / max)

func _update_glitch(hp_ratio: float) -> void:
	if not _glitch_mat:
		return
	# efeito começa a aparecer abaixo de 75% HP, máximo em 0%
	var intensity := clampf((0.75 - hp_ratio) / 0.75, 0.0, 1.0)
	_glitch_mat.set_shader_parameter("intensity", intensity)
	_glitch_overlay.visible = intensity > 0.01
