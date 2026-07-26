extends Node

class_name Global_data

@export var terrain_data_holder : Array[Terrain_data]
@export var map_objects : Array[Map_object]

@export var ally_team : Array[Character_stats] = []
@export var enemy_data : Array[Character_stats]

@export var map_data_path : Array[String] = []


func _ready() -> void:
	for ch in ally_team:
		ch.new()

func reset_data():
	ally_team.clear()
	ally_team.append(load("uid://d2mat2b43iwxg"))
	ally_team.append(load("uid://dg6k5myc0u1ir"))
	for ch in ally_team:
		ch.new()
