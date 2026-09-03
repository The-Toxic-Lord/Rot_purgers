extends Node2D

class_name Map_editor

@export var map_size := Vector2i(30, 30):
	set(value):
		map_size = value
		await update_map_size()
		map_node_size = map_size * 64
		await limit_camera()

@onready var camera : Camera2D = %Map_editor_camera
var map_node_size : Vector2
var dragging := false

enum modes { TERRAIN, OBJECTS, ENEMY }
var paint_mode : modes = modes.TERRAIN:
	set(value):
		paint_mode = value
		match value:
			modes.TERRAIN:
				show_height()
			modes.OBJECTS:
				hide_height()
			modes.ENEMY:
				hide_height()
var painting := false
var erasing := false

var selected_terrain_data : Terrain_data
@onready var current_map : TileMapLayer = %Terrain_map
var map_rect : Rect2i
var selected_height := 60
var selected_depth := 0
var cell_to_height_line : Dictionary[Vector2i, LineEdit] = {}
var cell_to_depth_line : Dictionary[Vector2i, LineEdit] = {}
var terrain_map_data : Dictionary[Vector2i, Terrain_data] = {}

@onready var main_node : Main_node = get_parent()
var selected_object : Map_object
var object_map_data : Dictionary[Vector2i, Map_object] = {}

var enemy_map_data : Dictionary[Vector2i, Character_stats] = {}
var cell_to_enemy_node : Dictionary[Vector2i, Node2D] = {}

func _ready() -> void:
	set_process(false)
	await update_map_size()
	map_node_size = map_size * 64
	await limit_camera()

func update_map_size():
	map_rect = Rect2i(0, 0, map_size.x, map_size.y)
	var used_cells : Array[Vector2i] = %Terrain_map.get_used_cells()
	for cell in used_cells:
		if !map_rect.has_point(cell):
			%Terrain_map.erase_cell(cell)
			if cell_to_height_line.has(cell):
				cell_to_height_line[cell].queue_free()
				cell_to_height_line.erase(cell)
	for x in map_size.x:
		for y in map_size.y:
			var cell := Vector2i(x, y)
			if used_cells.has(cell):
				continue
			%Terrain_map.set_cell(cell, 0, Vector2i.ZERO)

func limit_camera():
	var camera_size : Vector2 = Vector2(1920, 1080) / camera.zoom.x
	if (camera_size.x - map_node_size.x)/2 > 250 / camera.zoom.x:
		camera.position.x = map_node_size.x / 2
	else:
		camera.position.x = clamp(camera.position.x, camera_size.x / 2 - 250 / camera.zoom.x, map_node_size.x - camera_size.x / 2 + 250 / camera.zoom.x)
	if (camera_size.y - map_node_size.y)/2 > 0:
		camera.position.y = map_node_size.y / 2
	else:
		camera.position.y = clamp(camera.position.y, -300 / camera.zoom.x + camera_size.y / 2, map_node_size.y + 300 / camera.zoom.x - camera_size.y / 2)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom_in"):
		var _mouse_pos : Vector2 = event.position
		for dead_zone : Rect2 in %Map_Editor_UI.mouse_dead_zone:
			if dead_zone.has_point(_mouse_pos):
				return
		var mouse_pos : Vector2 = get_global_mouse_position()
		camera.zoom += Vector2(0.05,0.05)
		camera.zoom = camera.zoom.clamp(Vector2(0.25,0.25), Vector2(2,2))
		camera.position += mouse_pos - get_global_mouse_position()
		await limit_camera()
	elif event.is_action_pressed("zoom_out"):
		var _mouse_pos : Vector2 = event.position
		for dead_zone : Rect2 in %Map_Editor_UI.mouse_dead_zone:
			if dead_zone.has_point(_mouse_pos):
				return
		var mouse_pos : Vector2 = get_global_mouse_position()
		camera.zoom -= Vector2(0.05,0.05)
		camera.zoom = camera.zoom.clamp(Vector2(0.25,0.25), Vector2(2,2))
		camera.position += mouse_pos - get_global_mouse_position()
		await limit_camera()
	if event is not InputEventJoypadMotion and event is not InputEventMouseMotion:
		var action : String = what_action_is_event(event)
		if action != "":
			match action:
				"drag":
					if event.is_pressed():
						dragging = true
						drag_mouse_position = get_viewport().get_mouse_position()
						pre_drag_lab_box_position = camera.position
						set_process(true)
					elif event.is_released():
						dragging = false
						set_process(false)
	if event is InputEventMouseButton:
		var mouse_pos : Vector2 = event.position
		for dead_zone : Rect2 in %Map_Editor_UI.mouse_dead_zone:
			if dead_zone.has_point(mouse_pos):
				return
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if event.is_pressed():
					painting = true
					set_process(true)
				if event.is_released():
					prev_cell = Vector2i(-1, -1)
					painting = false
					set_process(false)
			MOUSE_BUTTON_RIGHT:
				if painting:
					return
				if event.is_pressed():
					erasing = true
					set_process(true)
				if event.is_released():
					erasing = false
					set_process(false)

var drag_mouse_position : Vector2
var pre_drag_lab_box_position : Vector2
var actionArray : Array[String] = [
	"drag"
]

func what_action_is_event(event) -> String:
	for action in actionArray:
		if event.is_action(action):
			return action
	return ""

var prev_cell : Vector2i = Vector2i(-1, -1)
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if dragging:
		var current_mouse_position : Vector2 = get_viewport().get_mouse_position()
		camera.position = pre_drag_lab_box_position + drag_mouse_position - current_mouse_position
		await limit_camera()
	if painting:
		match paint_mode:
			modes.TERRAIN:
				if selected_terrain_data == null:
					return
				var cell : Vector2i = %Terrain_map.local_to_map(%Terrain_map.get_global_mouse_position())
				if map_rect.has_point(cell):
					change_terrain(cell)
			modes.OBJECTS:
				if selected_object == null:
					return
				var cell : Vector2i = %Object_map.local_to_map(%Object_map.get_global_mouse_position())
				if map_rect.has_point(cell):
					change_object(cell)
			modes.ENEMY:
				var cell : Vector2i = %Enemy_map.local_to_map(%Enemy_map.get_global_mouse_position())
				if map_rect.has_point(cell) and prev_cell != cell:
					change_enemy(cell)
					prev_cell = cell
	if erasing:
		match paint_mode:
			modes.TERRAIN:
				var cell : Vector2i = %Terrain_map.local_to_map(%Terrain_map.get_global_mouse_position())
				if map_rect.has_point(cell):
					remove_cell(cell)
			modes.OBJECTS:
				var cell : Vector2i = %Object_map.local_to_map(%Object_map.get_global_mouse_position())
				if map_rect.has_point(cell):
					remove_object(cell)
			modes.ENEMY:
				var cell : Vector2i = %Enemy_map.local_to_map(%Enemy_map.get_global_mouse_position())
				if map_rect.has_point(cell):
					remove_enemy(cell)

func change_terrain(cell : Vector2i):
	%Terrain_map.set_cell(cell, 0, selected_terrain_data.atlas_coord)
	if !cell_to_height_line.has(cell):
		make_cell_height(cell)
	elif !cell_to_height_line[cell].has_focus():
		cell_to_height_line[cell].text = str(selected_height)
	if !terrain_map_data.has(cell):
		terrain_map_data[cell] = selected_terrain_data.duplicate(true)
		terrain_map_data[cell].height = selected_height
		terrain_map_data[cell].depth = selected_depth
	elif terrain_map_data[cell].atlas_coord != selected_terrain_data.atlas_coord:
		terrain_map_data[cell] = selected_terrain_data.duplicate(true)
		terrain_map_data[cell].height = selected_height
		terrain_map_data[cell].depth = selected_depth
	elif !cell_to_height_line[cell].has_focus():
		terrain_map_data[cell].height = selected_height
		terrain_map_data[cell].depth = selected_depth
	if !cell_to_depth_line.has(cell) and selected_depth != 0:
		make_cell_depth(cell)
	elif cell_to_depth_line.has(cell):
		if selected_depth == 0:
			cell_to_depth_line[cell].queue_free()
			cell_to_depth_line.erase(cell)
			cell_to_height_line[cell].position += Vector2(0, 16)
		else:
			cell_to_depth_line[cell].text = str(selected_depth)

func change_object(cell : Vector2i):
	if !terrain_map_data.has(cell):
		return
	%Object_map.set_cell(cell, 0, selected_object.atlas_coord)
	object_map_data[cell] = selected_object.duplicate(true)

func remove_object(cell : Vector2i):
	if !object_map_data.has(cell):
		return
	object_map_data.erase(cell)
	%Object_map.erase_cell(cell)

func remove_cell(cell : Vector2i):
	if !cell_to_height_line.has(cell):
		return
	cell_to_height_line[cell].queue_free()
	cell_to_height_line.erase(cell)
	terrain_map_data.erase(cell)
	%Terrain_map.set_cell(cell, 0, Vector2i.ZERO)
	if cell_to_depth_line.has(cell):
		cell_to_depth_line[cell].queue_free()
		cell_to_depth_line.erase(cell)
	 
	remove_object(cell)

func make_cell_height(cell : Vector2i, _height : int = selected_height):
	var le := LineEdit.new()
	cell_to_height_line[cell] = le
	le.text = str(_height)
	le.custom_maximum_size = Vector2(32, 32)
	le.custom_minimum_size = Vector2(32, 32)
	le.position = cell as Vector2 * 64 + le.custom_minimum_size / 2
	le.add_theme_font_size_override("font_size", 14)
	le.alignment = HORIZONTAL_ALIGNMENT_CENTER
	le.text_submitted.connect(change_data_height.bind(cell))
	%Height_holder.add_child(le)

func make_cell_depth(cell : Vector2i, _depth : int = selected_depth):
	var le := LineEdit.new()
	cell_to_depth_line[cell] = le
	le.text = str(_depth)
	le.custom_maximum_size = Vector2(32, 32)
	le.custom_minimum_size = Vector2(32, 32)
	le.position = cell as Vector2 * 64 + le.custom_minimum_size / 2 + Vector2(0, 16)
	le.add_theme_font_size_override("font_size", 14)
	le.alignment = HORIZONTAL_ALIGNMENT_CENTER
	%Height_holder.add_child(le)
	le.text_submitted.connect(change_data_depth.bind(cell))
	cell_to_height_line[cell].position -= Vector2(0, 16)

func _on_map_editor_ui_generate_map() -> void:
	main_node.generate_map(terrain_map_data, object_map_data, enemy_map_data)

func hide_height():
	for le : LineEdit in cell_to_height_line.values():
		le.hide()
	for le : LineEdit in cell_to_depth_line.values():
		le.hide()

func show_height():
	for le : LineEdit in cell_to_height_line.values():
		le.show()
	for le : LineEdit in cell_to_depth_line.values():
		le.show()

func save_map_data(file_path : String):
	var save_data := Map_data.new()
	save_data.terrain_map_data = terrain_map_data
	save_data.object_map_data = object_map_data
	save_data.enemy_map_data = enemy_map_data
	save_data.map_size = map_size
	ResourceSaver.save(save_data, file_path)

func load_map_data(file_path : String):
	%Terrain_map.clear()
	%Object_map.clear()
	%Enemy_map.clear()
	
	for cell in cell_to_enemy_node:
		cell_to_enemy_node[cell].queue_free()
	cell_to_enemy_node.clear()
	for cell in cell_to_height_line:
		cell_to_height_line[cell].queue_free()
	cell_to_height_line.clear()
	for cell in cell_to_depth_line:
		cell_to_depth_line[cell].queue_free()
	cell_to_depth_line.clear()
	
	var save_data : Map_data = ResourceLoader.load(file_path)
	terrain_map_data = save_data.terrain_map_data
	object_map_data = save_data.object_map_data
	enemy_map_data = save_data.enemy_map_data
	map_size = save_data.map_size
	await update_map_size()
	%Map_Editor_UI.load_data(map_size)
	
	for cell in terrain_map_data:
		load_terrain(cell, terrain_map_data[cell])
	for cell in object_map_data:
		load_objects(cell, object_map_data[cell])
	for cell in enemy_map_data:
		load_enemy(cell, enemy_map_data[cell])

func load_terrain(cell : Vector2i, terr_data : Terrain_data):
	%Terrain_map.set_cell(cell, 0, terr_data.atlas_coord)
	if !cell_to_height_line.has(cell):
		make_cell_height(cell, terr_data.height)
	elif !cell_to_height_line[cell].has_focus():
		cell_to_height_line[cell].text = str(terr_data.height)
	if !cell_to_depth_line.has(cell) and terr_data.depth != 0:
		make_cell_depth(cell, terr_data.depth)
	elif cell_to_depth_line.has(cell):
		if selected_depth == 0:
			cell_to_depth_line[cell].queue_free()
			cell_to_depth_line.erase(cell)
			cell_to_height_line[cell].position += Vector2(0, 16)
		else:
			cell_to_depth_line[cell].text = str(terr_data.depth)

func load_objects(cell : Vector2i, map_obj : Map_object):
	%Object_map.set_cell(cell, 0, map_obj.atlas_coord)

func change_data_height(new_text : String, cell : Vector2i):
	cell_to_height_line[cell].release_focus()
	if new_text.is_empty():
		cell_to_height_line[cell].text = "0"
		terrain_map_data[cell].height = 0
		return
	if new_text.is_valid_int():
		terrain_map_data[cell].height = new_text.to_int()
		return

func change_data_depth(new_text : String, cell : Vector2i):
	cell_to_depth_line[cell].release_focus()
	if new_text.is_empty():
		cell_to_depth_line[cell].text = "0"
		terrain_map_data[cell].depth = 0
		return
	if new_text.is_valid_int():
		terrain_map_data[cell].depth = new_text.to_int()
		return

func change_enemy(cell : Vector2i):
	if !terrain_map_data.has(cell):
		return
	if enemy_map_data.has(cell):
		%Map_Editor_UI.load_enemy_data(enemy_map_data[cell])
	else:
		var selected_enemy : Character_stats = %Map_Editor_UI.selected_enemy_data
		enemy_map_data[cell] = selected_enemy.duplicate(true)
		var enemy_node : Enemy_node = load("uid://crpsmfv7vh63b").instantiate()
		add_child(enemy_node)
		enemy_node.position = 64 * cell + Vector2i(32, 32)
		enemy_node.update_sprite(selected_enemy.sprite)
		cell_to_enemy_node[cell] = enemy_node

func remove_enemy(cell : Vector2i):
	if !enemy_map_data.has(cell):
		return
	enemy_map_data.erase(cell)
	cell_to_enemy_node[cell].queue_free()
	cell_to_enemy_node.erase(cell)

func load_enemy(cell : Vector2i, enemy_data : Character_stats):
	var enemy_node : Enemy_node = load("uid://crpsmfv7vh63b").instantiate()
	add_child(enemy_node)
	enemy_node.position = 64 * cell + Vector2i(32, 32)
	enemy_node.update_sprite(enemy_data.sprite)
	cell_to_enemy_node[cell] = enemy_node








#
