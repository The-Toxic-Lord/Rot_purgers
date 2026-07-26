extends Resource

class_name Map_data


@export_storage var map_size : Vector2i

@export_storage var terrain_map_data : Dictionary[Vector2i, Terrain_data] = {}
@export_storage var object_map_data : Dictionary[Vector2i, Map_object] = {}
@export_storage var enemy_map_data : Dictionary[Vector2i, Character_stats] = {}



@export var music : AudioStream
enum map_end_conditions { ENEMY, DOOR }
@export var end_condition : map_end_conditions
@export var magic_cost_adjustment : float = 1.0
@export_range(0, 3) var rot_stage : int = 0
@export var text_data : Text_data
