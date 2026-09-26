extends Resource

class_name Map_object

@export var name : String
@export var passable := true
@export var sprite : Texture2D
@export var atlas_coord : Vector2i
@export var node_UID : String
@export var direction := Map_generator.directions.N

enum types { STATIC, SPAWN, EXIT }
@export var object_type : types = types.STATIC
@export var extra_data : String
