extends Map_generator

class_name Tutorial

func load_map(map : Map_data):
	await get_tree().process_frame
	BattleHandler.map_gen = self
	ObjectLink.map_gen = self
	terrain_map = map.terrain_map_data
	object_map = map.object_map_data
	map_data = map
	await spawn_cells()
	await calculate_boundary()
	await move_selector_to_spawn()
	await spawn_objects()
	
	GlobalData.map_magic_cost_adjustment = 1.0
	GlobalData.ally_team.clear()
	GlobalData.ally_team.append(load("uid://c8uo7wqbb15qk"))
	GlobalData.ally_team[0].new()
	await %Map_UI.populate_spawn_list()
	
	BattleHandler.map_gen = self
	await BattleHandler.new_battle_start()
	await spawn_enemies(map.enemy_map_data)
	map_loaded.emit()
	if map_data.text_data != null:
		freze_selector = true
		DialogueBalloon.start(map_data.text_data, "t1")
		await DialogueManager.dialogue_ended
		freze_selector = false
	tutorial_sequence()

func tutorial_sequence():
	await get_tree().process_frame
	DialogueBalloon.start(map_data.text_data, "t2")
	while true:
		if %Camera_position.movement_bools[0]:
			break
		await get_tree().create_timer(0.1).timeout
	DialogueBalloon.start(map_data.text_data, "t3")
	while true:
		if %Camera_position.movement_bools[1]:
			break
		await get_tree().create_timer(0.1).timeout
	DialogueBalloon.start(map_data.text_data, "t4")
	while true:
		if %Camera_position.movement_bools[2]:
			break
		await get_tree().create_timer(0.1).timeout
	DialogueBalloon.start(map_data.text_data, "t5")
	while true:
		if ally_spawn_check:
			break
		await get_tree().create_timer(0.1).timeout
	DialogueBalloon.start(map_data.text_data, "t6")
	while true:
		if spawn_move_check:
			break
		await get_tree().create_timer(0.1).timeout
	DialogueBalloon.start(map_data.text_data, "t7")
	while true:
		if move_check:
			break
		await get_tree().create_timer(0.1).timeout
	DialogueBalloon.start(map_data.text_data, "t8")
	while true:
		if spawn_attack_check:
			break
		await get_tree().create_timer(0.1).timeout
	DialogueBalloon.start(map_data.text_data, "t9")
	while true:
		if bound_skill_check:
			break
		await get_tree().create_timer(0.1).timeout
	DialogueBalloon.start(map_data.text_data, "t10")
	while true:
		if unbound_skill_check:
			break
		await get_tree().create_timer(0.1).timeout
	DialogueBalloon.start(map_data.text_data, "t11")
	while true:
		if skill_order_check:
			break
		await get_tree().create_timer(0.1).timeout
	DialogueBalloon.start(map_data.text_data, "t12")
	while true:
		if %Map_UI.execution_check:
			break
		await get_tree().create_timer(0.1).timeout
	DialogueBalloon.start(map_data.text_data, "t13")
	while true:
		if end_turn_check:
			break
		await get_tree().create_timer(0.1).timeout
	DialogueBalloon.start(map_data.text_data, "t14")
	while true:
		if undo_check:
			break
		await get_tree().create_timer(0.1).timeout
	DialogueBalloon.start(map_data.text_data, "t15")
	await DialogueManager.dialogue_ended
	%Map_UI._on_turn_menu_exit()

var ally_spawn_check := false
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
	ally_spawn_check = true

var spawn_move_check := false
var spawn_attack_check := false
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
			spawn_attack_check = true
	
	move_cells.erase(ch_node.map_pos)
	if st == states.MOVE:
		for ally in BattleHandler.allies:
			move_cells.erase(ally.map_pos)
		spawn_move_check = true
	
	
	for cell in move_cells:
		var move_zone : Node3D = load(state_to_zone[st]).instantiate()
		add_child(move_zone)
		move_zone.position = map_cells[cell].position
		select_zones[cell] = move_zone

var move_check := false
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
	state = states.SELECT
	move_check = true

var bound_skill_check := false
func make_bound_skill(skill : Skill_base):
	var i := 0
	
	skill_animation_target_cell = skill.skill_map.animation_target + selected_char.map_pos
	
	for damage_cell in skill.skill_map.damage_cells:
		var damage_zone : Node3D = load("uid://bnwwdeckahhsa").instantiate()
		add_child(damage_zone)
		damage_zone.name = "damage_zone_" + str(i)
		i += 1
		if map_cells.has(selected_char.map_pos + damage_cell):
			damage_zone.position = map_cells[selected_char.map_pos + damage_cell].position
		else:
			damage_zone.position = Vector3((selected_char.map_pos.x + damage_cell.x) * cell_size, 0, 
			(selected_char.map_pos.y + damage_cell.y) * cell_size)
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
			move_zone.position = Vector3((selected_char.map_pos.x + move_cell.x) * cell_size, 0, 
			(selected_char.map_pos.y + move_cell.y) * cell_size)
		select_zones[selected_char.map_pos + move_cell] = move_zone
	
	if selected_char.current_direction != Map_generator.directions.N:
		rotate_skill(directions.N)
	if selected_char.can_move:
		start_skill_move_position = selected_char.map_pos
	bound_skill_check = true

var unbound_skill_check := false
func make_unboun_skill(skill : Skill_base):
	var i := 0
	
	skill_animation_target_cell = skill.skill_map.animation_target + selected_char.map_pos
	unbound_spell_center = selected_cell
	
	for damage_cell in skill.skill_map.damage_cells:
		var damage_zone : Node3D = load("uid://bnwwdeckahhsa").instantiate()
		add_child(damage_zone)
		damage_zone.name = "damage_zone_" + str(i)
		i += 1
		if map_cells.has(selected_cell + damage_cell):
			damage_zone.position = map_cells[selected_cell + damage_cell].position
		else:
			damage_zone.position = Vector3((selected_char.map_pos.x + damage_cell.x) * cell_size, 0, 
			(selected_char.map_pos.y + damage_cell.y) * cell_size)
		select_zones[selected_cell + damage_cell] = damage_zone
	
	var range_cells := get_flow_cells(selected_char.map_pos, skill.max_dist,
	 true, true, skill.max_height_difference, true, false)
	
	i = 0
	
	for cell in range_cells:
		var move_zone : Node3D = load("uid://crfwn05yop7k6").instantiate()
		add_child(move_zone)
		move_zone.name = "move_zone_" + str(i)
		unbound_spell_range[cell] = move_zone
		if map_cells.has(cell):
			move_zone.position = map_cells[cell].position
		else:
			move_zone.position = Vector3(cell.x * cell_size, 0, cell.y * cell_size)
		i += 1
	
	for cell in select_zones:
		if unbound_spell_range.has(cell):
			unbound_spell_range[cell].hide()
	unbound_skill_check = true

var end_turn_check := false

var undo_check := false
func _input(event: InputEvent) -> void:
	if DialogueBalloon.is_working:
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
				undo_check = true
				return
			if char_node.is_defending:
				char_node.can_attack = true
				char_node.is_defending = false
				undo_check = true
				return
			if char_node.can_undo_move:
				if char_positions.has(char_node.previous_map_pos):
					# ADD Error sound
					return
				char_positions.erase(char_node.map_pos)
				await char_node.undo_move(map_cells)
				char_positions[char_node.map_pos] = char_node
				undo_check = true
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

var skill_order_check := false
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
	skill_order_check = true



#
