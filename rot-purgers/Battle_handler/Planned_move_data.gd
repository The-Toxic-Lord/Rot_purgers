extends Resource

class_name Planned_move_data

var target_cell : Vector2i
var select_zones : Array[Vector2i]
var dir : Map_generator.directions

func _init(_target_cell : Vector2i, _select_zones : Array[Vector2i], 
_dir : Map_generator.directions) -> void:
	target_cell = _target_cell
	select_zones = _select_zones
	dir = _dir
