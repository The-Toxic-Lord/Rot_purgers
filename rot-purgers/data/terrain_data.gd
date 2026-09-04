extends Resource

class_name Terrain_data

@export var sprite : Texture2D
@export var atlas_coord : Vector2i
@export var passable : bool = true
@export var height := 0
@export var depth := 0
@export var floor_material : Material
@export var wall_material : Material
@export var can_be_modified : bool = true
