extends Node3D

class_name Map_generator

var neighbors_sides : Array[Vector2i] = [
	Vector2i.UP,
	Vector2i.RIGHT,
	Vector2i.DOWN,
	Vector2i.LEFT,
]

enum states { SELECT, MOVE, ATTACK, MENU, SKILL }
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
var selected_skill : Skill_base

var freze_selector := false

var char_positions : Dictionary[Vector2i, Character_node] = {}
var select_zones : Dictionary[Vector2i, Node3D] = {}
var unbound_spell_range : Dictionary[Vector2i, Node3D] = {}
var unbound_spell_center : Vector2i

var map_data : Map_data

signal map_loaded

func load_map(map : Map_data):
	await get_tree().process_frame
	terrain_map = map.terrain_map_data
	object_map = map.object_map_data
	map_data = map
	await spawn_cells()
	await calculate_boundary()
	await move_selector_to_spawn()
	await spawn_objects()
	await %Map_UI.populate_spawn_list()
	
	BattleHandler.map_gen = self
	await BattleHandler.new_battle_start()
	await spawn_enemies(map.enemy_map_data)
	map_loaded.emit()
	if map_data.text_data != null:
		freze_selector = true
		DialogueBalloon.show_text(map_data.text_data)
		await DialogueBalloon.text_read
		freze_selector = false

func start(_terrain_map : Dictionary[Vector2i, Terrain_data], 
_object_map : Dictionary[Vector2i, Map_object], enemy_map : Dictionary[Vector2i, Character_stats]):
	terrain_map = _terrain_map
	object_map = _object_map
	await spawn_cells()
	await calculate_boundary()
	await move_selector_to_spawn()
	await spawn_objects()
	await %Map_UI.populate_spawn_list()
	
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
		map_cell.name = str(cell)
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
	selected_cell = focus_cell
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
	if state == states.SKILL:
		if !selected_skill.skill_map.bound_to_char:
			if !unbound_spell_range.has(map_cell_to_data_cell[map_cell]):
				return
	%Selector.position = map_cell.position
	var prev_selector_cell := selected_cell
	selected_map_cell = map_cell
	selected_cell = map_cell_to_data_cell[selected_map_cell]
	if char_positions.has(selected_cell):
		%Map_UI.show_mini_stats(char_positions[selected_cell].stats)
	else:
		%Map_UI.hide_mini_stats()
	if state == states.SKILL:
		turn_to_selection()
		if !selected_skill.skill_map.bound_to_char:
			move_skill(selected_cell, prev_selector_cell)

func set_selector(cell : Vector2i):
	selected_cell = cell
	%Selector.position = map_cells[cell].position
	if char_positions.has(selected_cell):
		%Map_UI.show_mini_stats(char_positions[selected_cell].stats)

func turn_to_selection():
	var angle : float
	var dir : Vector2 = (selected_cell - selected_char.map_pos)
	dir = dir.normalized()
	angle = dir.angle_to(dir_to_vector[selected_char.current_direction])
	angle = rad_to_deg(angle)
	if angle > -50 and angle < 50:
		return
	var id : int = dir_arr.find(selected_char.current_direction)
	var new_dir : directions
	if angle > 50 and angle < 140:
		if id == 0:
			id = 4
		new_dir = dir_arr[id - 1]
	elif angle < -50 and angle > -140:
		if id == 3:
			id = -1
		new_dir = dir_arr[id + 1]
	else:
		if id >= 2:
			id -= 4
		new_dir = dir_arr[id + 2]
	selected_char.turn(new_dir, true)
	await selected_char.direction_changed
	if selected_skill.skill_map.bound_to_char:
		rotate_skill(selected_char.previous_direction)

var spawn_zones : Dictionary[Vector2i, Node3D] = {}
var exit_zones : Dictionary[Vector2i, Node3D] = {}

func spawn_objects():
	for cell in object_map:
		var zone : Node3D = load(object_map[cell].node_UID).instantiate()
		add_child(zone)
		zone.position = map_cells[cell].position
		match object_map[cell].name: 
			"spawn_zone":
				spawn_zones[cell] = zone
			"exit_zone":
				exit_zones[cell] = zone

func _input(event: InputEvent) -> void:
	if DialogueBalloon.dialogue_in_progress:
		return
	if BattleHandler.state != Battle_handler.states.PLAYER:
		return
	if event.is_action_pressed("rotate_skill"):
		if !selected_skill.skill_map.bound_to_char:
			rotate_unbound_skill()
		return
	if event.is_action_pressed("undo"):
		if char_positions.has(selected_cell):
			var char_node : Character_node = char_positions[selected_cell]
			if char_node.has_order:
				BattleHandler.remove_order(char_node)
				char_node.has_order = false
				char_node.can_attack = true
				return
			if char_node.is_defending:
				char_node.can_attack = true
				char_node.is_defending = false
				return
			if char_node.can_undo_move:
				if char_positions.has(char_node.previous_map_pos):
					# ADD Error sound
					return
				char_positions.erase(char_node.map_pos)
				await char_node.undo_move(map_cells)
				char_positions[char_node.map_pos] = char_node
		return
	if event.is_action_pressed("menu_back"):
		match state:
			states.MOVE, states.ATTACK:
				state = states.MENU
				clear_select_zone()
				%Map_UI.open_char_action_menu(selected_char, 1)
			states.SELECT:
				state = states.MENU
				%Map_UI.open_turn_menu()
			states.MENU:
				%Map_UI.close_all()
			states.SKILL:
				state = states.MENU
				clear_select_zone()
				%Map_UI.back_to_skill_selection()
		return
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
						states.SKILL:
							if !selected_skill.skill_map.bound_to_char:
								if !check_unbound_skill_height():
									return
							add_skill_order()

func spawn_ally(ch : Character_stats):
	var char_node : Character_node = load(ch.node_UID).instantiate()
	add_child(char_node)
	var cell : Vector2i = selected_cell
	char_node.position = spawn_zones[cell].position
	char_node.stats = ch
	char_node.name = ch.name
	char_node.is_enemy = false
	char_positions[cell] = char_node
	char_node.map_pos = selected_cell
	%Map_UI.show_mini_stats(char_positions[selected_cell].stats)
	BattleHandler.allies.append(char_node)
	selected_char = char_node
	%Map_UI.open_char_action_menu(char_node)

func spawn_select_zone(ch_node : Character_node, st : states):
	var move_cells : Array[Vector2i] = []
	
	var dist : int
	var ignore_chars : bool = true
	var ignore_enemies : bool = true
	match st:
		states.MOVE:
			dist = ch_node.stats.move_speed
			ignore_chars = false
			ignore_enemies = false
			move_cells = get_flow_cells(ch_node.map_pos, dist, ignore_chars, ignore_enemies, ch_node.stats.jump_height)
		states.ATTACK:
			for target in get_targets(ch_node):
				move_cells.append(target.map_pos)
	
	move_cells.erase(ch_node.map_pos)
	if st == states.MOVE:
		for ally in BattleHandler.allies:
			move_cells.erase(ally.map_pos)
	
	
	for cell in move_cells:
		var move_zone : Node3D = load(state_to_zone[st]).instantiate()
		add_child(move_zone)
		move_zone.position = map_cells[cell].position
		select_zones[cell] = move_zone

func get_flow_cells(start_cell : Vector2i, dist : int = 1, ignore_chars := true, ignore_enemies := true,
height_limit : int = 9999, ignore_player := true) -> Array[Vector2i]:
	var select_cells : Array[Vector2i] = []
	var border : Array[Vector2i] = [start_cell]
	dist += 1
	for i in dist:
		var new_border : Array[Vector2i] = []
		for cell in border:
			select_cells.append(cell)
			for neib in neighbors_sides:
				var check_cell : Vector2i = cell + neib
				if !terrain_map.has(check_cell):
					continue
				if !terrain_map[check_cell].passable:
					continue
				if object_map.has(check_cell):
					if !object_map[check_cell].passable:
						continue
				if char_positions.has(check_cell) and !ignore_chars:
					if BattleHandler.enemies.has(char_positions[check_cell]) and !ignore_enemies:
						continue
					if BattleHandler.allies.has(char_positions[check_cell]) and !ignore_player:
						continue
				var current_height : int = terrain_map[cell].height
				var ch_c_h : int = terrain_map[check_cell].height
				if ch_c_h - current_height > height_limit:
					continue
				if !border.has(check_cell) and !select_cells.has(check_cell) and !new_border.has(check_cell):
					new_border.append(check_cell)
		border = new_border
	
	return select_cells

func get_targets(char_node : Character_node) -> Array[Character_node]:
	var a_star := AStarGrid2D.new()
	a_star.region = selector_boundary
	a_star.cell_size = Vector2i(1,1)
	a_star.default_compute_heuristic = AStarGrid2D.HEURISTIC_CHEBYSHEV
	a_star.default_estimate_heuristic = AStarGrid2D.HEURISTIC_CHEBYSHEV
	a_star.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	a_star.update()
	
	a_star.fill_solid_region(a_star.region, false)
	a_star.update()
	
	var targets : Array[Character_node] = []
	
	for enemy in BattleHandler.enemies:
		var path : Array[Vector2i] = a_star.get_id_path(char_node.map_pos, enemy.map_pos)
		if path.size() <= char_node.stats.attack_distance + 1:
			var height : int = terrain_map[enemy.map_pos].height
			if height - terrain_map[char_node.map_pos].height <= char_node.stats.attack_height:
				targets.append(enemy)
	return targets

func clear_select_zone():
	for cell in select_zones:
		select_zones[cell].queue_free()
	select_zones.clear()
	for cell in unbound_spell_range:
		unbound_spell_range[cell].queue_free()
	unbound_spell_range.clear()

func move_character():
	BattleHandler.start_animation_freeze()
	camera.follow_target = selected_char
	char_positions.erase(selected_char.map_pos)
	selected_char.move(selected_cell, terrain_map, select_zones.keys(), selector_boundary, map_cells)
	clear_select_zone()
	await selected_char.move_finished
	camera.follow_target = null
	BattleHandler.stop_animation_freeze()
	selected_char.can_move = false
	update_char_position(selected_char, selected_cell)
	if exit_zones.has(selected_cell):
		BattleHandler.end_battle()
		return
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
	selected_char.has_order = true
	state = states.SELECT

func state_select():
	state = states.SELECT

func move_camera(ch_node : Character_node):
	%Camera_position.move_target = ch_node.position

func set_camera_target(char_node : Character_node = null):
	camera.follow_target = char_node

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
		var char_node : Character_node = load(enemy_map[cell].node_UID).duplicate(true).instantiate()
		add_child(char_node)
		char_node.position = map_cells[cell].position
		char_node.stats = enemy_map[cell]
		char_node.stats.new()
		char_node.name = enemy_map[cell].name
		char_node.map_pos = cell
		if map_data != null:
			char_node.set_rot(map_data.rot_stage)
		char_node.turn(enemy_map[cell].start_dir, true)
		BattleHandler.enemies.append(char_node)
		char_positions[cell] = char_node

func remove_enemy(ch_node : Character_node):
	char_positions.erase(ch_node.map_pos)
	ch_node.queue_free()

func display_skill(skill : Skill_base):
	selected_skill = skill
	
	if skill.skill_map.bound_to_char:
		make_bound_skill(skill)
	else:
		make_unboun_skill(skill)

func make_bound_skill(skill : Skill_base):
	var i := 0
	
	for damage_cell in skill.skill_map.damage_cells:
		var damage_zone : Node3D = load("uid://bnwwdeckahhsa").instantiate()
		add_child(damage_zone)
		damage_zone.name = "damage_zone_" + str(i)
		i += 1
		if map_cells.has(selected_char.map_pos + damage_cell):
			damage_zone.position = map_cells[selected_char.map_pos + damage_cell].position
		else:
			damage_zone.position = Vector3(damage_cell.x * cell_size, 0, damage_cell.y * cell_size)
		select_zones[selected_char.map_pos + damage_cell] = damage_zone
	
	i = 0
	
	for move_cell in skill.skill_map.move_cells:
		var move_zone : Node3D = load("uid://oklfeugj4gp7").instantiate()
		add_child(move_zone)
		move_zone.name = "move_zone_" + str(i)
		i += 1
		if map_cells.has(selected_char.map_pos + move_cell):
			move_zone.position = map_cells[selected_char.map_pos + move_cell].position
		else:
			move_zone.position = Vector3(move_cell.x * cell_size, 0, move_cell.y * cell_size)
		select_zones[selected_char.map_pos + move_cell] = move_zone
	
	if selected_char.current_direction != Map_generator.directions.N:
		rotate_skill(directions.N)

func make_unboun_skill(skill : Skill_base):
	var i := 0
	
	unbound_spell_center = selected_cell
	
	for damage_cell in skill.skill_map.damage_cells:
		var damage_zone : Node3D = load("uid://bnwwdeckahhsa").instantiate()
		add_child(damage_zone)
		damage_zone.name = "damage_zone_" + str(i)
		i += 1
		if map_cells.has(selected_cell + damage_cell):
			damage_zone.position = map_cells[selected_cell + damage_cell].position
		else:
			damage_zone.position = Vector3(damage_cell.x * cell_size, 0, damage_cell.y * cell_size)
		select_zones[selected_cell + damage_cell] = damage_zone
	
	var range_cells := get_flow_cells(selected_cell, skill.max_dist)
	
	i = 0
	
	for cell in range_cells:
		var move_zone : Node3D = load("uid://bfinhl1dtgkyo").instantiate()
		add_child(move_zone)
		move_zone.name = "move_zone_" + str(i)
		unbound_spell_range[cell] = move_zone
		if map_cells.has(cell):
			move_zone.position = map_cells[cell].position
		else:
			move_zone.position = Vector3(cell.x * cell_size, 0, cell.y * cell_size)
	
	for cell in select_zones:
		if unbound_spell_range.has(cell):
			unbound_spell_range[cell].hide()

enum directions { N, E, S, W }
var dir_arr : Array[directions] = [directions.N, directions.E, directions.S, directions.W]
var dir_to_rad : Dictionary[directions, float] = {
	directions.N : 0,
	directions.E : PI/2,
	directions.S : PI,
	directions.W : 3*PI/2
}
var dir_to_vector : Dictionary[directions, Vector2i] = {
	directions.N : Vector2i(0, -1),
	directions.S : Vector2i(0, 1),
	directions.E : Vector2i(1, 0),
	directions.W : Vector2i(-1, 0)
}

func rotate_skill(prev_dir : directions):
	if selected_skill == null:
		return
	var new_select_zone : Dictionary[Vector2i, Node3D] = {}
	for cell in select_zones:
		var zone : Node3D = select_zones[cell]
		var temp_v : Vector2 = cell - selected_char.map_pos
		var angle : float = dir_to_rad[selected_char.current_direction] - dir_to_rad[prev_dir]
		temp_v = temp_v.rotated(angle)
		var new_cell : Vector2i = selected_char.map_pos + Vector2i(round(temp_v.x), round(temp_v.y))
		new_select_zone[new_cell] = zone
		if map_cells.has(new_cell):
			zone.position = map_cells[new_cell].position
		else:
			zone.position = Vector3(new_cell.x * cell_size, 0, new_cell.y * cell_size)
	select_zones.clear()
	select_zones = new_select_zone

func move_skill(new_pos : Vector2i, old_pos : Vector2i):
	unbound_spell_center = new_pos
	var dir := new_pos - old_pos
	var new_select_zones : Dictionary[Vector2i, Node3D] = {}
	
	for cell in select_zones:
		if unbound_spell_range.has(cell):
			unbound_spell_range[cell].show()
	
	for cell in select_zones:
		var new_pos_cell := cell + dir
		if map_cells.has(new_pos_cell):
			select_zones[cell].position = map_cells[new_pos_cell].position
			new_select_zones[new_pos_cell] = select_zones[cell]
		else:
			select_zones[cell].position = Vector3(new_pos_cell.x * cell_size, 0, new_pos_cell.y * cell_size)
			new_select_zones[new_pos_cell] = select_zones[cell]
	select_zones.clear()
	select_zones = new_select_zones
	
	
	for cell in select_zones:
		if unbound_spell_range.has(cell):
			unbound_spell_range[cell].hide()

func rotate_unbound_skill():
	for cell in select_zones:
		if unbound_spell_range.has(cell):
			unbound_spell_range[cell].show()
	
	var new_select_zone : Dictionary[Vector2i, Node3D] = {}
	var angle : float = PI / 2
	for cell in select_zones:
		var zone : Node3D = select_zones[cell]
		var temp_v : Vector2 = cell - unbound_spell_center
		temp_v = temp_v.rotated(angle)
		var new_cell : Vector2i = unbound_spell_center + Vector2i(round(temp_v.x), round(temp_v.y))
		new_select_zone[new_cell] = zone
		if map_cells.has(new_cell):
			zone.position = map_cells[new_cell].position
		else:
			zone.position = Vector3(new_cell.x * cell_size, 0, new_cell.y * cell_size)
	select_zones.clear()
	select_zones = new_select_zone
	
	for cell in select_zones:
		if unbound_spell_range.has(cell):
			unbound_spell_range[cell].hide()

func add_skill_order():
	if !selected_skill.skill_map.bound_to_char:
		pass
	var damage_cells : Array[Vector2i] = []
	var move_cells : Array[Vector2i] = []
	for cell in select_zones:
		var zone_name := select_zones[cell].name
		if zone_name.contains("damage_zone_"):
			damage_cells.append(cell)
		else:
			move_cells.append(cell)
	BattleHandler.add_skill(selected_char, selected_skill, damage_cells, move_cells, selected_cell)
	clear_select_zone()
	%Map_UI.flush_skill_menu()
	selected_char.can_attack = false
	selected_char.has_order = true
	state = states.SELECT

func check_unbound_skill_height() -> bool:
	for cell in select_zones:
		if !terrain_map.has(cell):
			continue
		var height : int = terrain_map[cell].height
		var h_diff : int = height - terrain_map[selected_char.map_pos].height
		if h_diff <= selected_skill.max_height_difference:
			return true
	return false

func load_save():
	var game_save : Game_save = Game_save.new()
	game_save = ResourceLoader.load("user://save.tres")
	
	get_parent().current_map_id = game_save.current_map_id
	terrain_map = game_save.terrain_map
	object_map = game_save.object_map
	
	await spawn_cells()
	await calculate_boundary()
	await move_selector_to_spawn()
	await spawn_objects()
	
	GlobalData.ally_team = game_save.ally_team
	await %Map_UI.populate_spawn_list()
	
	BattleHandler.map_gen = self
	await BattleHandler.new_battle_start()
	BattleHandler.order_array = game_save.orders
	await load_chars(game_save)

func load_chars(game_save : Game_save):
	for save_char_data in game_save.char_data:
		var char_node : Character_node = load(save_char_data.stats.node_UID).instantiate()
		add_child(char_node)
		await char_node.load_state(save_char_data)
		char_node.name = save_char_data.name
		char_node.position = map_cells[char_node.map_pos].position
		char_positions[char_node.map_pos] = char_node
		char_node.turn(char_node.current_direction)
		if char_node.is_enemy:
			BattleHandler.enemies.append(char_node)
		else:
			BattleHandler.allies.append(char_node)











#
