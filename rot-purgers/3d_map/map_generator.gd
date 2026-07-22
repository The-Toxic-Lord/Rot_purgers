extends Node3D

class_name Map_generator

var neighbors_sides : Array[Vector2i] = [
	Vector2i.UP,
	Vector2i.RIGHT,
	Vector2i.DOWN,
	Vector2i.LEFT,
]

enum states { SELECT, MOVE, ATTACK, MENU }
var state : states = states.SELECT
var state_to_zone : Dictionary[states, String] = {
	states.MOVE : "uid://bfinhl1dtgkyo",
	states.ATTACK : "uid://bnwwdeckahhsa"
}

@onready var camera : Camera_controller = %Camera_position

@export var cell_size := 2.0
var map_cells : Dictionary[Vector2i, Map_cell] = {}
var map_cell_to_data_cell : Dictionary[Map_cell, Vector2i] = {}
var selector_boundary : Rect2i

var terrain_map : Dictionary[Vector2i, Terrain_data]
var object_map : Dictionary[Vector2i, Map_object]

var selected_char : Character_node
var selected_map_cell : Map_cell
var selected_cell : Vector2i

var freze_selector := false

var char_positions : Dictionary[Vector2i, Character_node] = {}
var select_zones : Dictionary[Vector2i, Node3D] = {}

func start(_terrain_map : Dictionary[Vector2i, Terrain_data], 
_object_map : Dictionary[Vector2i, Map_object], enemy_map : Dictionary[Vector2i, Character_stats]):
	terrain_map = _terrain_map
	object_map = _object_map
	await spawn_cells()
	await calculate_boundary()
	await move_selector_to_spawn()
	await add_spawn_zones()
	
	BattleHandler.map_gen = self
	await BattleHandler.new_battle_start()
	await spawn_enemies(enemy_map)

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
	if freze_selector or BattleHandler.state != Battle_handler.states.PLAYER:
		return
	%Selector.position = map_cell.position
	selected_map_cell = map_cell
	selected_cell = map_cell_to_data_cell[selected_map_cell]
	if char_positions.has(selected_cell):
		%Map_UI.show_mini_stats(char_positions[selected_cell].stats)
	else:
		%Map_UI.hide_mini_stats()

var spawn_zones : Dictionary[Vector2i, Node3D] = {}
func add_spawn_zones():
	for cell in object_map:
		if object_map[cell].name == "spawn_zone":
			var zone : Node3D = load("uid://b77u0ogcrnmlx").instantiate()
			add_child(zone)
			zone.position = map_cells[cell].position
			spawn_zones[cell] = zone

func _input(event: InputEvent) -> void:
	if BattleHandler.state != Battle_handler.states.PLAYER:
		return
	if event.is_action_pressed("menu_back"):
		match state:
			states.MOVE, states.ATTACK:
				state = states.MENU
				clear_select_zone()
				%Map_UI.open_char_action_menu(selected_char)
			states.SELECT:
				state = states.MENU
				%Map_UI.open_turn_menu()
			states.MENU:
				%Map_UI.close_all()
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if event.is_pressed():
					match state:
						states.SELECT:
							if freze_selector:
								return
							if char_positions.has(selected_cell):
								state = states.MENU
								selected_char = char_positions[selected_cell]
								%Map_UI.open_char_action_menu(char_positions[selected_cell])
								return
							if spawn_zones.has(selected_cell):
								state = states.MENU
								$Map_UI.open_spawn_menu()
								return
						states.MOVE:
							if select_zones.has(selected_cell):
								move_character()
							else:
								pass
								# ADD error sound
						states.ATTACK:
							if select_zones.has(selected_cell) and char_positions.has(selected_cell):
								attack_character()
								return
							else:
								pass
								# ADD error sound

func spawn_ally(ch : Character_stats):
	var char_node : Character_node = load("uid://cf0xldnvalt5g").instantiate()
	add_child(char_node)
	var cell : Vector2i = selected_cell
	char_node.position = spawn_zones[cell].position
	char_node.stats = ch
	char_node.name = ch.name
	char_positions[cell] = char_node
	char_node.map_pos = selected_cell
	%Map_UI.show_mini_stats(char_positions[selected_cell].stats)
	BattleHandler.allies.append(char_node)
	selected_char = char_node
	%Map_UI.open_char_action_menu(char_node)

func spawn_select_zone(ch_node : Character_node, st : states):
	var move_cells : Array[Vector2i] = []
	var border : Array[Vector2i] = [ch_node.map_pos]
	
	var dist : int
	match st:
		states.MOVE:
			dist = ch_node.stats.move_speed + 1
		states.ATTACK:
			dist = ch_node.stats.attack_distance + 1
	
	for i in dist:
		var new_border : Array[Vector2i] = []
		for cell in border:
			move_cells.append(cell)
			for neib in neighbors_sides:
				var check_cell : Vector2i = cell + neib
				if !terrain_map.has(check_cell):
					continue
				if !terrain_map[check_cell].passable:
					continue
				if object_map.has(check_cell):
					if !object_map[check_cell].passable:
						continue
				if char_positions.has(check_cell) and st == states.MOVE:
					if BattleHandler.enemies.has(char_positions[check_cell]):
						continue
				var current_height : int = terrain_map[ch_node.map_pos].height
				var ch_c_h : int = terrain_map[check_cell].height
				if ch_c_h - current_height > ch_node.stats.jump_height:
					continue
				if !border.has(check_cell) and !move_cells.has(check_cell) and !new_border.has(check_cell):
					new_border.append(check_cell)
		border = new_border
	
	move_cells.erase(ch_node.map_pos)
	if state == states.MOVE:
		for ally in BattleHandler.allies:
			move_cells.erase(ally.map_pos)
	
	for cell in move_cells:
		var move_zone : Node3D = load(state_to_zone[st]).instantiate()
		add_child(move_zone)
		move_zone.position = map_cells[cell].position
		select_zones[cell] = move_zone

func clear_select_zone():
	for cell in select_zones:
		select_zones[cell].queue_free()
	select_zones.clear()

func move_character():
	BattleHandler.start_animation_freeze()
	camera.reparent(selected_char)
	camera.move_target = Vector3.ZERO
	char_positions.erase(selected_char.map_pos)
	selected_char.move(selected_cell, terrain_map, select_zones.keys(), selector_boundary, map_cells)
	clear_select_zone()
	await selected_char.move_finished
	camera.reparent(self)
	camera.move_target = camera.position
	BattleHandler.stop_animation_freeze()
	selected_char.can_move = false
	update_char_position(selected_char, selected_cell)
	if selected_char.can_attack:
		state = states.MENU
		%Map_UI.open_char_action_menu(selected_char)
		return
	state = states.SELECT

func update_char_position(char_node : Character_node, new_pos : Vector2i):
	char_positions[new_pos] = char_node
	char_node.map_pos = new_pos

func attack_character():
	clear_select_zone()
	BattleHandler.add_attack(selected_char, char_positions[selected_cell])
	selected_char.can_attack = false
	state = states.SELECT

func state_select():
	state = states.SELECT

func move_camera(ch_node : Character_node):
	%Camera_position.move_target = ch_node.position

func try_mouse_raycast():
	var spaceState := get_world_3d().direct_space_state
	var mousePos := get_viewport().get_mouse_position()
	var _camera := get_tree().root.get_camera_3d()
	
	var rayOrigin := _camera.project_ray_origin(mousePos)
	var rayEnd = rayOrigin + _camera.project_ray_normal(mousePos) * 200
	var params = PhysicsRayQueryParameters3D.create(rayOrigin, rayEnd)
	params.collide_with_areas = true
	var rayArray = spaceState.intersect_ray(params)
	
	if !rayArray.is_empty():
		var collider = rayArray["collider"]
		if collider is Area3D and collider.name == "Mouse_detector":
			move_selector(collider.get_parent())

func spawn_enemies(enemy_map : Dictionary[Vector2i, Character_stats]):
	for cell in enemy_map:
		var char_node : Character_node = load("uid://cf0xldnvalt5g").instantiate()
		add_child(char_node)
		char_node.position = map_cells[cell].position
		char_node.stats = enemy_map[cell]
		char_node.stats.new()
		char_node.name = enemy_map[cell].name
		char_node.map_pos = cell
		BattleHandler.enemies.append(char_node)
		char_positions[cell] = char_node

func remove_enemy(ch_node : Character_node):
	char_positions.erase(ch_node.map_pos)
	ch_node.queue_free()








#
