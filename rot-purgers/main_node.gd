extends Node

class_name Main_node

var map_editor : Map_editor
var map_generator : Map_generator

func _on_map_editor_pressed() -> void:
	map_editor = load("uid://cx7jdespo6tsb").instantiate()
	add_child(map_editor)
	%Map_editor.hide()

func generate_map(terrain_map_data : Dictionary[Vector2i, Terrain_data],
 object_map_data : Dictionary[Vector2i, Map_object], enemy_map_data : Dictionary[Vector2i, Character_stats]):
	map_generator = load("uid://buyr0671du0pe").instantiate()
	add_child(map_generator)
	map_editor.queue_free()
	map_generator.start(terrain_map_data, object_map_data, enemy_map_data)
