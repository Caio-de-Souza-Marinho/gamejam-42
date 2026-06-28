extends Resource

class_name LevelData

# Qtd of sublevel (1-1, 1-2, 1-3, 1-4, 2-1, ....)
@export var num_sub_levels := 6
# Qtd of rooms per level
@export var num_rooms := 4

@export var room_size := Vector2i(384, 384)
@export var room_scene: PackedScene

@export var min_enemies_per_room := 5
@export var max_enemies_per_room := 10

#Props
@export var max_props_per_room := 9
@export var props: Array[PackedScene]

# Scenes exports
@export var h_corridor: PackedScene
@export var v_corridor: PackedScene
@export var corridor_size: Vector2i = Vector2i(192, 175)

# Array of the enemies that will spawn in that room
@export var enemy_scenes: Array[PackedScene]

# Array of the items that will have a prob to drop in that room
# Based on "level_store_data -> item_data(the item itself), item_prob(the probability of drop)
@export var store_data: Array[LevelStoreData]
