extends Node2D

class_name LevelRoom
@onready var room_walls: Dictionary[Vector2i, TileMapLayer] = {
	Vector2i.UP: %WallUp,
	Vector2i.RIGHT: %WallRight,
	Vector2i.DOWN: %WallDown,
	Vector2i.LEFT: %WallLeft 
}

@onready var title_data: TileMapLayer = $TileData


@onready var clear_door_nodes: Dictionary[Vector2i, TileMapLayer] = {
	Vector2i.UP: %DoorUP,
	Vector2i.RIGHT: %DoorRight,
	Vector2i.DOWN: %DoorDown,
	Vector2i.LEFT: %DoorLeft 
}

var titles: Array[Vector2i]
var is_cleared: bool

func _ready() -> void:
	close_all_walls()
	register_titles()
	

# ------------- DEBUGG --------
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("ui_accept"):
		#lock_room()
	#if event.is_action_pressed("ui_cancel"):
		#unlock_room()
		
func register_titles() -> void:
	for title in title_data.get_used_cells():
		titles.append(title)

func create_props(data: LevelData) -> void:
	for i in data.max_props_per_room:
		var title_coord: Vector2i = titles.pick_random()
		var tile_position: Vector2 = title_data.map_to_local(title_coord)
		var random_prop: PackedScene = data.props.pick_random()
		var instance: Area2D = random_prop.instantiate()
		instance.position = tile_position
		add_child(instance)

func lock_room() -> void:
	for  direction in clear_door_nodes:
		var wall_door = room_walls[direction]
		var clear_door = clear_door_nodes[direction] 
		
		if wall_door and not wall_door.enabled:
			clear_door.enabled = true
			
	
func unlock_room() -> void:
	for  direction in clear_door_nodes:
		clear_door_nodes[direction].enabled = false
		
func open_wall(direction: Vector2i) -> void:
	if room_walls.has(direction):
		room_walls[direction].enabled = false

func close_all_walls() -> void:
	for key in room_walls:
		room_walls[key].enabled = true


func _on_player_detector_body_entered(body: Node2D) -> void:
	EventBus.on_player_room_entered.emit(self)
