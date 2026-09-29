extends Node

class_name Global_data

@export var ally_team : Array[Character_stats] = []
@export var enemy_data : Array[Character_stats]

@export var map_data_path : Array[String] = []

@export var map_magic_cost_adjustment : float

var dir_to_vect : Dictionary[Map_generator.directions, Vector2i] = {
	Map_generator.directions.N : Vector2i(0, -1),
	Map_generator.directions.S : Vector2i(0, 1),
	Map_generator.directions.E : Vector2i(1, 0),
	Map_generator.directions.W : Vector2i(-1, 0)
}
var oposing_dir : Dictionary[Map_generator.directions, Map_generator.directions] = {
	Map_generator.directions.N : Map_generator.directions.S,
	Map_generator.directions.S : Map_generator.directions.N,
	Map_generator.directions.E : Map_generator.directions.W,
	Map_generator.directions.W : Map_generator.directions.E
}
var neighbors_sides : Array[Vector2i] = [
	Vector2i.UP,
	Vector2i.RIGHT,
	Vector2i.DOWN,
	Vector2i.LEFT,
]

@export var dead_chars : Array[String] = []

func clear_data():
	ally_team.clear()
	dead_chars.clear()






#
