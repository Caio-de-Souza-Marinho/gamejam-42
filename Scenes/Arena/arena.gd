extends Node2D

# ---------------------- CURSOR --------------------
@export var arena_cursor: Texture2D
@export var levels: Array[LevelData]

@onready var map_controller: MapController = $UI/MapController
@onready var enemy_spawner: EnemySpawner = $EnemySpawner
@onready var total_coins: Label = %TotalCoins
@onready var coin_sound: AudioStreamPlayer = $CoinSound

@onready var dungeon: Node2D = $Dungeon

# -------------------- MAP GENERATION ----------------

var grid: Dictionary[Vector2i, LevelRoom] = {}
var start_room_coord: Vector2i
var end_room_coord: Vector2i
var grid_cell_size: Vector2i
 
var player: Player
var current_room: LevelRoom
var level_data: LevelData

var current_level_index: int = 0
var current_sub_level: int = 1
var portals_crossed: int = 0
var _current_num_rooms: int = 0

var upgrade_screen: UpgradeScreen

@export var player_scene: PackedScene

# -----------------x-----------------------------------

func _ready() -> void:
	Global.reset_run()

	EventBus.on_player_room_entered.connect(_on_player_room_entered)
	EventBus.on_room_cleared.connect(_on_room_cleared)
	EventBus.on_portal_reached.connect(_on_portal_reached)
	EventBus.on_coin_picked.connect(_on_coin_picked)

	level_data = levels[0]
	Cursor.sprite.texture = arena_cursor

	upgrade_screen = UpgradeScreen.new()
	add_child(upgrade_screen)

	generate_dungeon()


func generate_dungeon() -> void:
	
	for child in dungeon.get_children():
		child.queue_free()

	await get_tree().process_frame

	current_room = null
	map_controller.reset()
	enemy_spawner.reset()

	if player:
		player.queue_free()
		Global.player_ref = null
		# ------- MAP GEN ---------
	grid_cell_size = Vector2i(
		level_data.room_size.x + level_data.corridor_size.x,
		level_data.room_size.y + level_data.corridor_size.y
	)
	# +1 sala a cada 2 portais cruzados
	_current_num_rooms = level_data.num_rooms + portals_crossed / 2

	generate_level_layout()
	select_special_rooms()
	create_rooms()
	create_corridors()

	# Escurece o dungeon progressivamente: branco → roxo escuro ao longo de 10 portais
	var t := clampf(portals_crossed / 10.0, 0.0, 1.0)
	dungeon.modulate = Color.WHITE.lerp(Color(0.35, 0.18, 0.45), t)

	load_game_selection()
	#spawn_player()
	
	var first_room: LevelRoom = grid[Vector2i.ZERO]
	first_room.is_cleared = true
	# ------------------------

func spawn_player() -> void:
	player = player_scene.instantiate()
	var start_room: LevelRoom = grid[start_room_coord]
	player.position = start_room.position + Vector2(level_data.room_size) / 2.0
	add_child(player)
	
func generate_level_layout() -> void:
	grid.clear()

	print("Creating grid layout")
	
	## (0, 0)
	var current_coord := Vector2i.ZERO
	grid[current_coord] = null
	
	# UP = (0, 1), DOWN = (0, -1), RIGHT = (1, 0), LEFT = (-1, 0)
	var direction := [Vector2i.UP, Vector2i.DOWN, Vector2i.RIGHT, Vector2i.LEFT]
	
	while grid.size() < _current_num_rooms:
		if randf() >  0.5:
			current_coord = grid.keys().pick_random()
		
		var random_direction = direction.pick_random()
		var next_coord = current_coord + random_direction
		
		var attemps = 0 
		while grid.has(next_coord) and attemps < 10:
			random_direction = direction.pick_random()
			next_coord = current_coord + random_direction
			attemps += 1
			
		if not grid.has(next_coord):
			grid[next_coord] = null

	# ------- DEBUGGIN ----------
	#for key: Vector2i in grid.keys():
		#print(key)
		

func create_rooms() -> void:
	print("Creating Rooms")
	
	for room_coord: Vector2i in grid.keys():
		var room_instance: LevelRoom = level_data.room_scene.instantiate()
		room_instance.position = room_coord * grid_cell_size
		dungeon.add_child(room_instance)
		room_instance.create_props(level_data)
		
		grid[room_coord] = room_instance
		
		if room_coord == end_room_coord:
			room_instance.is_cleared = true
			room_instance.setup_room_as_portal()
		connect_rooms(room_coord, room_instance)

func create_corridors() -> void:
	print("Creating corridors")
	for room_coord: Vector2i in grid.keys():
		var room_instance: LevelRoom = grid[room_coord]
		
		#Right cnn
		var right_neighbor = room_coord + Vector2i.RIGHT
		if grid.has(right_neighbor):
			var corridor: Node2D = level_data.h_corridor.instantiate()
			corridor.position = room_instance.position + Vector2(
				grid_cell_size.x / 2.0, 0
			)
			dungeon.add_child(corridor)
		#Down cnn
		var down_neighbor = room_coord + Vector2i.DOWN
		if grid.has(down_neighbor):
			var corridor: Node2D = level_data.v_corridor.instantiate()
			corridor.position = room_instance.position + Vector2(
				0, grid_cell_size.x / 2.0
			)
			dungeon.add_child(corridor)
		

func connect_rooms(room_coord: Vector2i, room_instance: LevelRoom) -> void:
	var directions := [Vector2i.UP, Vector2i.DOWN, Vector2i.RIGHT, Vector2i.LEFT]
	for direction in directions:
		var neighbor_coord = room_coord + direction
		if grid.has(neighbor_coord):
			room_instance.open_wall(direction)
	

func select_special_rooms() -> void:
	start_room_coord = Vector2i.ZERO
	end_room_coord = find_farthest_room()
	print("start_room_coord=", start_room_coord)
	print("end_room_coord=", end_room_coord)
	
func find_farthest_room() ->  Vector2i:
	var farthest_room_cord := start_room_coord
	var max_dist := 0.0
	
	for room_coord: Vector2i in grid.keys():
		var dist  = start_room_coord.distance_to(room_coord)
		if dist > max_dist:
			max_dist = dist
			farthest_room_cord = room_coord
	return farthest_room_cord

func find_coord_from_room(room: LevelRoom) -> Vector2i:
	for coord: Vector2i in grid:
		if grid[coord] == room:
			return coord
	return Vector2i.MAX

func _on_player_room_entered(room: LevelRoom) -> void:
	if room == current_room: return
	
	current_room = room

	var absolute_coord = find_coord_from_room(room)
	var relativa_coord = absolute_coord - start_room_coord
	map_controller.update_on_room_entered(relativa_coord)
	
	if not room.is_cleared:
		room.lock_room()
		enemy_spawner.spawn_enemies(level_data, room, portals_crossed)

func load_game_selection() -> void:
	player = Global.get_player().instantiate()
	add_child(player)

	var first_room: LevelRoom = grid[Vector2i.ZERO]
	var spawn_pos: Marker2D = first_room.player_spawn_pos
	player.global_position = spawn_pos.global_position
	player.weapon_controller.equip_weapon(Global.selected_weapon)
	Global.player_ref = player

func _on_room_cleared() -> void:
	current_room.unlock_room()
	current_room.is_cleared = true
	
func _on_portal_reached() -> void:
	await Transition.show_transition_in().finished

	# Atualiza estado do nível antes de mostrar a tela de upgrade
	var going_to_menu := false
	if current_sub_level < level_data.num_sub_levels:
		current_sub_level += 1
	else:
		current_level_index += 1
		if current_level_index < levels.size():
			current_sub_level = 1
			level_data = levels[current_level_index]
		else:
			going_to_menu = true

	if going_to_menu:
		Transition.transition_to("res://Scenes/UI/Victory.tscn")
		return

	upgrade_screen.show_screen(portals_crossed)
	portals_crossed += 1
	await Transition.show_transition_out().finished
	await upgrade_screen.confirmed

	await Transition.show_transition_in().finished
	upgrade_screen.hide_screen()
	await generate_dungeon()
	await Transition.show_transition_out().finished
func _on_coin_picked() -> void:
	coin_sound.play()
	total_coins.text = str(Global.coins)
