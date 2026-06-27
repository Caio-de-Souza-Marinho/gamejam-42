extends CanvasLayer
class_name HUD

@onready var health_bar: TextureProgressBar = find_child("HealthBar", true, false)
#@onready var health_bar: TextureProgressBar = $HealthBar

func _ready() -> void:
	if health_bar == null:
		push_error("HealthBar não encontrado no HUD")
	EventBus.on_player_health_updated.connect(_on_player_health_updated)

func _on_player_health_updated(current: float, max: float) -> void:
	if health_bar == null:
		return
	health_bar.value = current / max
