@tool
extends TileMapLayer

class_name Skill_map_data_maker

@export var bake_data := false:
	set(value):
		bake()

@export var data : Skill_map_data

func bake():
	data = Skill_map_data.new()
	var used_cells := get_used_cells()
	for cell in used_cells:
		var atlas : Vector2i = get_cell_atlas_coords(cell)
		match atlas:
			Vector2i(0, 0):
				data.damage_cells.append(cell)
			Vector2i(4, 0):
				data.move_cells.append(cell)
			Vector2i(7, 1):
				data.bound_to_char = true
