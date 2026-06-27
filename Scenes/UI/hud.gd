extends CanvasLayer
class_name HUD

@onready var health_bar: TextureProgressBar = find_child("HealthBar")

func _ready() -> void:
	EventBus.on_player_health_updated.connect(_on_player_health_updated)
	
func _on_player_health_updated(current: float, max: float) -> void:
	health_bar.value = current / max
