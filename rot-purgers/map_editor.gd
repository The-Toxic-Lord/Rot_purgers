extends Node2D

class_name Map_editor

var map_size := Vector2i(30, 30):
	set(value):
		map_size = value
		await update_map_size()
		map_node_size = map_size * 64
		await limit_camera()

@onready var camera : Camera2D = %Map_editor_camera
var map_node_size : Vector2
var dragging := false
var painting := false
var erasing := false

var selected_terrain_data : Terrain_data
@onready var current_map : TileMapLayer = %Terrain_map
var map_rect : Rect2i
@export var terrain_data_to_atlas : Dictionary[Terrain_data, Vector2i]
var selected_height := 60
var cell_to_height_line : Dictionary[Vector2i, LineEdit] = {}

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
		var mouse_pos : Vector2 = get_global_mouse_position()
		camera.zoom += Vector2(0.05,0.05)
		camera.zoom = camera.zoom.clamp(Vector2(0.25,0.25), Vector2(2,2))
		camera.position += mouse_pos - get_global_mouse_position()
		await limit_camera()
	elif event.is_action_pressed("zoom_out"):
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
				if selected_terrain_data == null or erasing:
					return
				if event.is_pressed():
					painting = true
					set_process(true)
				if event.is_released():
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

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if dragging:
		var current_mouse_position : Vector2 = get_viewport().get_mouse_position()
		camera.position = pre_drag_lab_box_position + drag_mouse_position - current_mouse_position
		await limit_camera()
	if painting:
		var cell : Vector2i = %Terrain_map.local_to_map(%Terrain_map.get_global_mouse_position())
		if map_rect.has_point(cell):
			change_cell(cell)
	if erasing:
		var cell : Vector2i = %Terrain_map.local_to_map(%Terrain_map.get_global_mouse_position())
		if map_rect.has_point(cell):
			if cell_to_height_line.has(cell):
				cell_to_height_line[cell].queue_free()
				cell_to_height_line.erase(cell)
				%Terrain_map.set_cell(cell, 0, Vector2i.ZERO)

func change_cell(cell : Vector2i):
	%Terrain_map.set_cell(cell, 0, terrain_data_to_atlas[selected_terrain_data])
	if !cell_to_height_line.has(cell):
		make_cell_height(cell)

func make_cell_height(cell : Vector2i):
	var le := LineEdit.new()
	cell_to_height_line[cell] = le
	le.text = str(selected_height)
	le.custom_maximum_size = Vector2(32, 32)
	le.custom_minimum_size = Vector2(32, 32)
	le.position = cell as Vector2 * 64 + le.custom_minimum_size / 2
	le.add_theme_font_size_override("font_size", 14)
	le.alignment = HORIZONTAL_ALIGNMENT_CENTER
	%Height_holder.add_child(le)












#
