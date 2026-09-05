extends Order_data

class_name Order_spawn

var stats : Character_stats
var target_cell : Vector2i
var dir : Map_generator.directions

func make_spawn_data(enemy_stats : Character_stats, _target_cell : Vector2i,
_dir : Map_generator.directions, _attacker : Character_node):
	stats = enemy_stats.duplicate(true)
	target_cell = _target_cell
	dir = _dir
	attacker = _attacker.get_path()
