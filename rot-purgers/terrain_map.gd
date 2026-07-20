@tool
extends TileMapLayer

class_name Terrain_map

@export var map_size : Vector2i = Vector2i(20, 20)
@export var base_height : int = 60
var cell_size := 64

@export var root : Node

@warning_ignore("unused_parameter")
func _update_cells(coords: Array[Vector2i], forced_cleanup: bool) -> void:
	changed.emit()

@export var clear_map : bool = false:
	set(value):
		clear_map = value
		if clear_map:
			self.clear()
			for x in map_size.x:
				for y in map_size.y:
					var cell := Vector2i(x, y)
					self.set_cell(cell, 0, Vector2i(0, 0))
			clear_map = false

@export var cell_to_label : Dictionary[Vector2i, Label]

func _on_changed() -> void:
	for cell in get_used_cells():
		var atlas_cell : Vector2i = get_cell_atlas_coords(cell)
		if atlas_cell == Vector2i.ZERO:
			if cell_to_label.has(cell):
				cell_to_label[cell].queue_free()
				cell_to_label.erase(cell)
				continue
			else:
				continue
		if cell_to_label.has(cell):
			continue
		make_label(cell)
		

func make_label(cell : Vector2i):
	var label := Label.new()
	label.text = str(base_height)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size = Vector2(64, 64)
	label.add_theme_font_size_override("font_size", 32)
	label.position = cell * cell_size
	cell_to_label[cell] = label
	
	self.add_child(label)
	label.owner = root









#
