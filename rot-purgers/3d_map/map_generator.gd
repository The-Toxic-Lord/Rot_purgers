extends Node3D

class_name Map_generator

@export var cell_size := 2.0
var map_cells : Dictionary[Vector2i, Map_cell] = {}
var map_cell_to_data_cell : Dictionary[Map_cell, Vector2i] = {}
var selector_boundary : Rect2i
var terrain_map : Dictionary[Vector2i, Terrain_data]
var object_map : Dictionary[Vector2i, Map_object]
var selected_cell : Map_cell

var freze_selector := false

func start(_terrain_map : Dictionary[Vector2i, Terrain_data], _object_map : Dictionary[Vector2i, Map_object]):
	terrain_map = _terrain_map
	object_map = _object_map
	await spawn_cells()
	await calculate_boundary()
	await move_selector_to_spawn()
	await add_spawn_zones()

func spawn_cells():
	for cell in terrain_map:
		var terr_data : Terrain_data = terrain_map[cell]
		var map_cell : Map_cell = load("uid://b57jse1cfeshi").instantiate()
		%Map_cell_holder.add_child(map_cell)
		map_cells[cell] = map_cell
		map_cell_to_data_cell[map_cell] = cell
		map_cell.mouse_entered.connect(move_selector.bind(map_cell))
		map_cell.position = Vector3(cell.x * cell_size, terr_data.height * 0.1 , cell.y * cell_size)
		map_cell.make_meshes(terrain_map, cell)

func calculate_boundary():
	var corners : Array[Vector2i] = [map_cells.keys()[0], map_cells.keys()[0]]
	for cell in map_cells:
		if corners[0].x > cell.x:
			corners[0].x = cell.x
		if corners[0].y > cell.y:
			corners[0].y = cell.y
		if corners[1].x < cell.x:
			corners[1].x = cell.x
		if corners[1].y < cell.y:
			corners[1].y = cell.y
	selector_boundary = Rect2i(corners[0], corners[1] - corners[0] + Vector2i(1, 1))
	var camera_boundary : Rect2 = Rect2((corners[0] - Vector2i(1, 1)) * cell_size,\
	 (selector_boundary.size + Vector2i(1, 1)) * cell_size)
	%Camera_position.move_boundary = camera_boundary

func move_selector_to_spawn():
	var focus_cell : Vector2i
	for cell in object_map:
		if object_map[cell].name == "spawn_zone":
			focus_cell = cell
			break
	%Selector.position = map_cells[focus_cell].position
	%Camera_position.position = %Selector.position
	%Camera_position.move_target = %Selector.position

func get_position_height(pos : Vector3) -> float:
	var cell : Vector2i = Vector2(round(pos.x), round(pos.z)) / 2
	if map_cells.has(cell):
		return terrain_map[cell].height * 0.1
	return 0.0

func move_selector(map_cell : Map_cell):
	if freze_selector:
		return
	%Selector.position = map_cell.position
	selected_cell = map_cell

var spawn_zones : Dictionary[Vector2i, Node3D] = {}
func add_spawn_zones():
	for cell in object_map:
		if object_map[cell].name == "spawn_zone":
			var zone : Node3D = load("uid://b77u0ogcrnmlx").instantiate()
			add_child(zone)
			zone.position = map_cells[cell].position
			spawn_zones[cell] = zone

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if event.is_pressed():
					if spawn_zones.has(map_cell_to_data_cell[selected_cell]):
						freze_selector = true
						$Map_UI.open_spawn_menu()

func spawn_ally(ch : Character):
	print(ch.name + " spawning")












#
