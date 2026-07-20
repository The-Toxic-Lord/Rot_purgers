@tool
extends Node3D

class_name test_map

var terrain_dict : Dictionary
@onready var terrain_map : TileMapLayer = %Terrain_map

@export var activate : bool = false:
	set(value):
		activate = value
		if activate:
			update_map()

func update_map():
	activate = false
	
