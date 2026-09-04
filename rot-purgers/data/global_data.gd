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









#
