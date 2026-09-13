extends Resource

class_name Planned_move_data

var target_cell : Vector2i
var select_zones : Array[Vector2i]
var dir : Map_generator.directions

func set_target(_target_cell : Vector2i, _select_zones : Array[Vector2i], 
_dir : Map_generator.directions) -> void:
	target_cell = _target_cell
	select_zones = _select_zones
	dir = _dir

var target_pos : Vector3
func set_3d(_target_pos : Vector3):
	target_pos = _target_pos
