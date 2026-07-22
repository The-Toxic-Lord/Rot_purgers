extends Resource

class_name Map_data


@export_storage var map_size : Vector2i

@export_storage var terrain_map_data : Dictionary[Vector2i, Terrain_data] = {}
@export_storage var object_map_data : Dictionary[Vector2i, Map_object] = {}
@export_storage var enemy_map_data : Dictionary[Vector2i, Character_stats] = {}
