extends CharacterBody2D
class_name Player

@export var data: PlayerData

@onready var visuals: Node2D = $Visuals
@onready var anim_sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var weapon_controller: WeaponController = $WeaponController

var can_move := true
var movement: Vector2
var direction: Vector2
var cooldown: float

func _ready() -> void:
	var max_hp := data.max_hp * (1.0 + Global.upgrade_hp)
	health_component.init_health(max_hp)
	EventBus.on_player_health_updated.emit(max_hp, max_hp)
	
func _process(delta: float) -> void:
	weapon_controller.target_pos = get_global_mouse_position()
	weapon_controller.rotate_weapon()
	
	cooldown -= delta
	if Input.is_action_pressed("shoot"):
		if cooldown <= 0:
			weapon_controller.current_weapon.use_weapon()
			cooldown = maxf(0.05, weapon_controller.current_weapon.data.cooldown * (1.0 - Global.upgrade_cooldown))

func _physics_process(_delta: float) -> void:
	if not can_move:
		return
	
	direction = Input.get_vector("move_left","move_right","move_up","move_down")
	if direction != Vector2.ZERO:
		movement = direction * (data.move_speed * (1.0 + Global.upgrade_speed))
		anim_sprite.play("move")
	else:
		movement = Vector2.ZERO
		anim_sprite.play("idle")
		
	velocity = movement
	move_and_slide()
	rotate_player()
	
func rotate_player() -> void:
	if direction != Vector2.ZERO:
		if direction.x > 0.1:
			visuals.scale = Vector2(1.25, 1.25)
		else:
			visuals.scale = Vector2(-1.25, 1.25)	

func _on_health_component_on_unit_damaged(amount: float) -> void:
	EventBus.on_player_health_updated.emit(health_component.current_health, health_component.max_health) 


func _on_health_component_on_unit_dead() -> void:
	can_move = false
	velocity = Vector2.ZERO
	move_and_slide()
	anim_sprite.play("dead")
	await get_tree().create_timer(1.0).timeout
	Transition.transition_to("res://Scenes/UI/main_menu.tscn")


func _on_health_component_on_unit_healed(amount: float) -> void:
	EventBus.on_player_health_updated.emit(health_component.current_health, health_component.max_health)
