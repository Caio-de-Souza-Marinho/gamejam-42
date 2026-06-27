extends CharacterBody2D
class_name Enemy

@export var max_health := 5.0
@export var collision_damage := 1.0
@export var dead_texture: Texture2D
@export_group("Enamy Chase")
@export var chase_speed := 40.0
@export_group("Enamy Weapon")
@export var move_speed := 40.0
@export var weapon: WeaponData

@onready var anim_sprite: AnimatedSprite2D = $AnimSprite
@onready var player_detector: Area2D = $PlayerDetector
@onready var hurt_sound: AudioStreamPlayer = $HurtSound
@onready var health_bar: ProgressBar = $HealthBar
@onready var health_component: HealthComponent = $HealthComponent
@onready var enemy_detector: Area2D = $EnemyDetector
#@onready var weapon_controller: WeaponController = $WeaponController
@onready var weapon_controller: WeaponController = get_node_or_null("WeaponController")

var can_move: bool = true
var is_killed: bool = false
var cooldown: float

func _ready() -> void:
	health_bar.value = 1.0
	health_component.init_health(max_health)
	
	if not weapon: return
	weapon_controller.equip_weapon(weapon)

func _process(delta: float) -> void:
	if not Global.player_ref: return
	rotate_enemy()
	manage_weapon(delta)

func manage_weapon(delta: float) -> void:
	if not weapon: return
	if not weapon_controller: return
	weapon_controller.target_pos = Global.player_ref.global_position
	weapon_controller.rotate_weapon()
	
	cooldown -= delta
	if cooldown <= 0:
		weapon_controller.current_weapon.use_weapon()
		cooldown = weapon_controller.current_weapon.data.cooldown

func _physics_process(delta: float) -> void:
	if not Global.player_ref: return
	if not can_move: return
	
	var dir := global_position.direction_to(Global.player_ref.global_position)
	for enemy: Enemy in enemy_detector.get_overlapping_bodies():
		if enemy != self and enemy.is_inside_tree():
			var vector = global_position - enemy.global_position
			dir += 10 * vector.normalized() / vector.length()
	
	velocity = dir * chase_speed
	move_and_slide()
	rotate_enemy()
	
func rotate_enemy() -> void:
	if global_position.x > Global.player_ref.global_position.x:
		anim_sprite.flip_h = true
	elif global_position.x < Global.player_ref.global_position.x:
		anim_sprite.flip_h = false

func enemy_dead() -> void:
	anim_sprite.play("die")
	await anim_sprite.animation_finished
	if is_killed: return
	
	is_killed = true
	#Global.create_dead_particle(dead_texture, global_position)
	#EventBus.on_enemy_die.emit()
	queue_free()

func _on_player_detector_body_entered(body: Node2D) -> void:
	body.health_component.take_damage(collision_damage)
	enemy_dead()# Replace with function body.

func _on_health_component_on_unit_dead() -> void:
	enemy_dead() # Replace with function body.

func _on_health_component_on_unit_damaged(amount: float) -> void:
	health_bar.value = health_component.current_health / max_health
	anim_sprite.material = Global.HIT_MATERIAL
	await get_tree().create_timer(0.1).timeout
	anim_sprite.material = null
