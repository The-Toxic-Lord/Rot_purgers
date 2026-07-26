extends Resource

class_name Save_char_data

@export_storage var can_move := true
@export_storage var can_attack := true
@export_storage var is_defending := false
@export_storage var has_order := false
@export_storage var map_pos : Vector2i
@export_storage var previous_map_pos : Vector2i
@export_storage var can_undo_move := false
@export_storage var stats : Character_stats
@export_storage var current_direction : Map_generator.directions
@export_storage var is_enemy : bool
@export_storage var name : String


func make(char_node : Character_node) -> void:
	can_move = char_node.can_move
	can_attack = char_node.can_attack
	is_defending = char_node.is_defending
	has_order = char_node.has_order
	can_undo_move = char_node.can_undo_move
	map_pos = char_node.map_pos
	previous_map_pos = char_node.previous_map_pos
	stats = char_node.stats
	current_direction = char_node.current_direction
	is_enemy = char_node.is_enemy
	name = char_node.name







#
