extends Node

class_name Global_data

@export var terrain_data_holder : Array[Terrain_data]
@export var map_objects : Array[Map_object]

@export var ally_team : Array[Character_stats] = []
@export var enemy_data : Array[Character_stats]

func _ready() -> void:
	for ch in ally_team:
		ch.new()
