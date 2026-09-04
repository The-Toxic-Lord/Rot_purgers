extends Node

class_name Global_data

@export var ally_team : Array[Character_stats] = []
@export var enemy_data : Array[Character_stats]

@export var map_data_path : Array[String] = []

@export var map_magic_cost_adjustment : float

func _ready() -> void:
	for ch in ally_team:
		ch.new()

func reset_data():
	ally_team.clear()
	ally_team.append(load("uid://d2mat2b43iwxg"))
	ally_team.append(load("uid://dg6k5myc0u1ir"))
	for ch in ally_team:
		ch.new()



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




#
