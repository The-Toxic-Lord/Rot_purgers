extends Node

class_name Enemy_manager

signal enemies_turn_ended

var map_gen : Map_generator
@export var temp : Array[Skill_able_data]
var char_planned_moves : Dictionary[Character_node, Planned_move_data] = {}
var occupied_cells : Array[Vector2i]

func _ready() -> void:
	ObjectLink.enemy_manager = self

func start_enemy_turn():
	char_planned_moves.clear()
	occupied_cells = map_gen.char_positions.keys().duplicate(true)
	await get_tree().process_frame
	for enemy in BattleHandler.enemies:
		#map_gen.set_camera_target(enemy)
		match enemy.stats.AI_type:
			Character_stats.AI_types.TURRET:
				await handle_turret_AI(enemy)
			Character_stats.AI_types.NORMAL:
				await handle_normal_AI(enemy)
			Character_stats.AI_types.CHARGER:
				await handle_charger_AI(enemy)
			Character_stats.AI_types.SPAWNER:
				await handle_spawner_AI(enemy)
	for enemy in char_planned_moves:
		enemy.make_planned_move(char_planned_moves[enemy])
		map_gen.update_char_position(enemy, char_planned_moves[enemy].target_cell)
	await get_tree().process_frame
	while true:
		await get_tree().create_timer(0.1).timeout
		var check := true
		for enemy in char_planned_moves:
			if !enemy.can_undo_move:
				check = false
		if check:
			break
	if !BattleHandler.order_array.is_empty():
		BattleHandler.execute_orders()
		await BattleHandler.orders_executed
	end_enemy_turn()

func end_enemy_turn():
	enemies_turn_ended.emit()

func handle_turret_AI(enemy : Character_node):
	var a_star := AStarGrid2D.new()
	a_star.region = map_gen.selector_boundary
	a_star.cell_size = Vector2i(1,1)
	a_star.default_compute_heuristic = AStarGrid2D.HEURISTIC_CHEBYSHEV
	a_star.default_estimate_heuristic = AStarGrid2D.HEURISTIC_CHEBYSHEV
	a_star.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	a_star.update()
	
	a_star.fill_solid_region(a_star.region, false)
	a_star.update()
	
	for ally in BattleHandler.allies:
		var path : Array[Vector2i] = a_star.get_id_path(enemy.map_pos, ally.map_pos)
		if path.size() <= enemy.stats.attack_distance + 1 + enemy.stats.move_speed:
			if path.size() <= enemy.stats.attack_distance + 1:
				var height : int = map_gen.terrain_map[ally.map_pos].height
				if abs(height - map_gen.terrain_map[enemy.map_pos].height) < enemy.stats.attack_height:
					BattleHandler.add_attack(enemy, ally)
					return
	
	#var target_cells : Array[Vector2i] = map_gen.get_flow_cells(enemy.map_pos, enemy.stats.attack_distance,
	#true, true, enemy.stats.attack_height)
	#var targets : Array[Character_node] = []
	#for cell in target_cells:
		#if map_gen.char_positions.has(cell):
			#var new_target : Character_node = map_gen.char_positions[cell]
			#if BattleHandler.allies.has(new_target):
				#targets.append(new_target)
	#if targets.is_empty():
		#return
	#var target : Character_node = targets.pick_random()
	#BattleHandler.add_attack(enemy, target)

func handle_normal_AI(enemy : Character_node):
	var move_cells : Array[Vector2i] = map_gen.get_flow_cells(enemy.map_pos, enemy.stats.move_speed,
	false, true, enemy.stats.jump_height, false)
	
	for cell in occupied_cells:
		move_cells.erase(cell)
	move_cells.insert(0, enemy.map_pos)
	if AI_can_use_skill(move_cells, enemy):
		enemy.stats.AI_type = Character_stats.AI_types.CHARGER
		return
	
	if AI_can_attack(move_cells, enemy):
		enemy.stats.AI_type = Character_stats.AI_types.CHARGER
		return

func handle_charger_AI(enemy : Character_node):
	var move_cells : Array[Vector2i] = map_gen.get_flow_cells(enemy.map_pos, enemy.stats.move_speed,
	false, true, enemy.stats.jump_height, false)
	
	for cell in occupied_cells:
		move_cells.erase(cell)
	move_cells.insert(0, enemy.map_pos)
	if AI_can_use_skill(move_cells, enemy):
		return
	
	if AI_can_attack(move_cells, enemy):
		return
	
	var a_star := AStarGrid2D.new()
	a_star.region = map_gen.selector_boundary
	a_star.cell_size = Vector2i(1,1)
	a_star.default_compute_heuristic = AStarGrid2D.HEURISTIC_CHEBYSHEV
	a_star.default_estimate_heuristic = AStarGrid2D.HEURISTIC_CHEBYSHEV
	a_star.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	a_star.update()
	
	a_star.fill_solid_region(a_star.region)
	for cell in map_gen.terrain_map:
		a_star.set_point_solid(cell, false)
	for ally in BattleHandler.allies:
		a_star.set_point_solid(ally.map_pos, true)
	a_star.update()
	
	var targets : Array[Character_node] = []
	var paths : Array[Array] = []
	
	for ally in BattleHandler.allies:
		a_star.set_point_solid(ally.map_pos, false)
		var new_path : Array[Vector2i] = a_star.get_id_path(enemy.map_pos, ally.map_pos, true)
		if !new_path.is_empty():
			paths.append(new_path)
			targets.append(ally)
		a_star.set_point_solid(ally.map_pos, true)
	
	if paths.is_empty():
		return
	
	var path_id := 0
	for i in paths.size():
		var ch_path : Array = paths[i]
		if ch_path.size() < paths[path_id].size():
			path_id = i
	
	var target_cell : Vector2i = paths[path_id].back()
	var move_cell := enemy.map_pos
	var distance : int = get_flow_distance(move_cell, target_cell)
	for cell in move_cells:
		var ch_dist : int = get_flow_distance(cell, target_cell)
		if ch_dist < distance:
			distance = ch_dist
			move_cell = cell
	
	if move_cell != enemy.map_pos:
		var move := Planned_move_data.new(move_cell, move_cells, Map_generator.directions.S)
		char_planned_moves[enemy] = move
		
		occupied_cells.erase(enemy.map_pos)
		occupied_cells.append(move_cell)
	
	#var skip := false
	#for path : Array[Vector2i] in paths:
		#if move_cells.has(path[path.size() - 2]):
			#await move_charger(path[path.size() - 2], enemy, move_cells)
			#skip = true
			#break
	#
	#if !skip:
		#for cell in move_cells:
			#var bb := false
			#if bb:
				#break
			#for neib in neib_side:
				#var t_c : Vector2i = neib + cell
				#if map_gen.char_positions.has(t_c):
					#if BattleHandler.allies.has(map_gen.char_positions[t_c]) and !skip and !bb:
						#await move_charger(cell, enemy, move_cells)
						#skip = true
						#bb = true
						#break
	
	#if !skip and !paths.is_empty():
	
	
	#if !paths.is_empty():
		#var id : int = 0
		#for i in paths.size():
			#if paths[i].size() < paths[id].size() and !map_gen.char_positions.keys().has(paths[i][enemy.stats.move_speed]):
				#id = i
		#for en in BattleHandler.enemies:
			#a_star.set_point_solid(en.map_pos, true)
		#a_star.set_point_solid(targets[id].map_pos, true)
		#for cell in move_cells:
			#a_star.set_point_solid(cell, false)
		#a_star.set_point_solid(enemy.map_pos, false)
		#var path : Array[Vector2i] = a_star.get_id_path(enemy.map_pos, targets[id].map_pos, true)
		#if path.is_empty() or path.size() == 1:
			#return
		#var cell : Vector2i
		#if path.size() >= enemy.stats.move_speed + 1:
			#cell = path[enemy.stats.move_speed]
		#else:
			#cell = path.back()
		#path.remove_at(0)
		#for p_c in path:
			#if p_c == cell:
				#break
			#if !move_cells.has(p_c):
				#return
		#
		#var move := Planned_move_data.new(cell, move_cells, Map_generator.directions.S)
		#char_planned_moves[enemy] = move
		#
		#occupied_cells.erase(enemy.map_pos)
		#occupied_cells.append(cell)
		
		#await move_charger(cell, enemy, move_cells)
	
	#for neib in neib_side:
		#if map_gen.char_positions.has(neib + enemy.map_pos):
			#if BattleHandler.allies.has(map_gen.char_positions[neib + enemy.map_pos]):
				#var height : int = map_gen.terrain_map[neib + enemy.map_pos].height
				#if abs(height - map_gen.terrain_map[enemy.map_pos].height) < enemy.stats.attack_height:
					#BattleHandler.add_attack(enemy, map_gen.char_positions[neib + enemy.map_pos])

func handle_spawner_AI(enemy : Character_node):
	var move_cells : Array[Vector2i] = map_gen.get_flow_cells(enemy.map_pos, enemy.stats.move_speed,
	false, true, enemy.stats.jump_height, false)
	
	for cell in occupied_cells:
		move_cells.erase(cell)
	move_cells.insert(0, enemy.map_pos)
	
	if !AI_can_spawn(move_cells, enemy):
		#ADD
		pass

func AI_can_spawn(move_cells : Array[Vector2i], enemy : Character_node) -> bool:
	move_cells.shuffle()
	for cell in move_cells:
		for n_c in neib_side:
			var new_cell : Vector2i = cell + n_c
			if !map_gen.map_cells.has(new_cell):
				continue
			if occupied_cells.has(new_cell):
				continue
			if !map_gen.terrain_map[new_cell].passable:
				continue
			occupied_cells.append(new_cell)
			var enemy_stats : Character_stats = ResourceLoader.load(enemy.stats.spawn_node_UUID)
			var dir : Map_generator.directions = map_gen.vector_to_dir[n_c]
			var move := Planned_move_data.new(cell, move_cells, dir)
			char_planned_moves[enemy] = move
			BattleHandler.add_spawn(enemy_stats, new_cell, dir, enemy)
			
			occupied_cells.erase(enemy.map_pos)
			occupied_cells.append(cell)
			
			#if cell != enemy.map_pos:
				#enemy.move(cell, map_gen.terrain_map, move_cells, 
				#map_gen.selector_boundary, map_gen.map_cells)
				#await enemy.move_finished
			#if enemy.current_direction != dir:
				#enemy.turn(dir)
				#await enemy.direction_changed
			
			#await map_gen.spawn_enemy(enemy_stats, new_cell, dir)
			return true
	return false

func AI_can_use_skill(move_cells : Array[Vector2i], enemy : Character_node) -> bool:
	var skill_possibilities : Array[Skill_able_data] = []
	for cell in move_cells:
		skill_possibilities.append_array(can_use_skills_in_position(enemy, cell))
	temp = skill_possibilities
	if !skill_possibilities.is_empty():
		# ADD difficulty paths
		# on hight difficulties enemies must evade damage cells in already issued orders
		# ADD maybe randomness to chosen skill among best, but this add time to calculation
		var max_targets := 0
		var frienly_targets := 0
		var chosen_possibility : Skill_able_data
		for skill_possible in skill_possibilities:
			if max_targets < skill_possible.enemy_targets.size():
				chosen_possibility = skill_possible
				max_targets = skill_possible.enemy_targets.size()
				frienly_targets = skill_possible.targets.size() - max_targets
			elif max_targets == skill_possible.enemy_targets.size() and\
			 frienly_targets > skill_possible.targets.size() - skill_possible.enemy_targets.size():
				chosen_possibility = skill_possible
				max_targets = skill_possible.enemy_targets.size()
				frienly_targets = skill_possible.targets.size() - max_targets
		
		var move := Planned_move_data.new(chosen_possibility.used_position, 
		move_cells, chosen_possibility.dir)
		char_planned_moves[enemy] = move
		occupied_cells.erase(enemy.map_pos)
		occupied_cells.append(chosen_possibility.used_position)
		
		#await move_charger(chosen_possibility.used_position, enemy, move_cells)
		#enemy.turn(chosen_possibility.dir)
		#await enemy.direction_changed
		BattleHandler.add_skill(enemy, chosen_possibility.skill, 
		chosen_possibility.damage_cells, chosen_possibility.move_cells, chosen_possibility.target_cell)
		return true
	return false

func AI_can_attack(move_cells : Array[Vector2i], enemy : Character_node) -> bool:
	var attack_possibilities : Dictionary[Vector2i, Array] = {}
	for cell in move_cells:
		@warning_ignore("confusable_local_declaration")
		var targets : Array[Vector2i] = can_attack_fom_position(
			enemy.stats.attack_distance, cell, enemy.stats.attack_height, enemy.position)
		if !targets.is_empty():
			attack_possibilities[cell] = targets
	
	if !attack_possibilities.is_empty():
		var chosen_possibility : Vector2i = attack_possibilities.keys().pick_random()
		var target : Vector2i = attack_possibilities[chosen_possibility].pick_random()
		
		var move := Planned_move_data.new(chosen_possibility, 
		move_cells, map_gen.vector_to_dir[target - chosen_possibility])
		char_planned_moves[enemy] = move
		occupied_cells.erase(enemy.map_pos)
		occupied_cells.append(chosen_possibility)
		
		#await move_charger(chosen_possibility, enemy, move_cells)
		BattleHandler.add_attack(enemy, map_gen.char_positions[target])
		return true
	return false

var neib_side : Array[Vector2i] = [
	Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT
]

func move_charger(cell : Vector2i, enemy : Character_node, move_cells : Array[Vector2i]):
	map_gen.char_positions.erase(enemy.map_pos)
	enemy.move(cell,map_gen.terrain_map, 
			move_cells, map_gen.selector_boundary,map_gen.map_cells)
	await enemy.move_finished
	await map_gen.update_char_position(enemy, enemy.map_pos)

func can_attack_fom_position(attack_distance : int, position_cell : Vector2i,
char_attack_height : int, attacker_pos : Vector3) -> Array[Vector2i]:
	var range_cells : Array[Vector2i] = map_gen.get_flow_cells(position_cell, attack_distance,
	true, true, 9999, true, true, true)
	var targers : Array[Vector2i] = []
	var char_height : int = map_gen.terrain_map[position_cell].height
	for cell in range_cells:
		if !map_gen.char_positions.has(cell):
			continue
		var char_node : Character_node = map_gen.char_positions[cell]
		if !BattleHandler.allies.has(char_node):
			continue
		var cell_height : int = map_gen.terrain_map[cell].height
		if abs(cell_height - char_height) > char_attack_height:
			continue
		if pretend_fire(attacker_pos, char_node.position):
			targers.append(cell)
	return targers

func can_use_skills_in_position(char_node : Character_node, 
position_cell : Vector2i) -> Array[Skill_able_data]:
	var skills_able_data : Array[Skill_able_data] = []
	for skill in char_node.stats.skills:
		if skill.magic_cost > char_node.stats.magic:
			continue
		if skill.skill_map.bound_to_char:
			skills_able_data.append_array(can_use_bound_skill_in_position(skill, position_cell))
		else:
			var char_height : int = map_gen.terrain_map[position_cell].height
			skills_able_data.append_array(can_use_unbound_skill_in_position(skill, 
			position_cell, char_height, char_node.map_pos))
	return skills_able_data

func can_use_bound_skill_in_position(skill : Skill_base, 
char_map_pos : Vector2i) -> Array[Skill_able_data]:
	var char_height : int = map_gen.terrain_map[char_map_pos].height
	var dir_able : Dictionary[Map_generator.directions, bool] = {
		Map_generator.directions.N : false,
		Map_generator.directions.E : false,
		Map_generator.directions.S : false,
		Map_generator.directions.W : false
	}
	var skill_able_data_arr : Array[Skill_able_data] = []
	for dir in Map_generator.directions.values():
		var damage_cells : Array[Vector2i] = skill.skill_map.damage_cells.duplicate(true)
		for i in damage_cells.size():
			damage_cells[i] += char_map_pos
		if dir != Map_generator.directions.N:
			damage_cells = rotare_skill_cells_around_position(damage_cells, char_map_pos, dir)
		for cell in damage_cells:
			if map_gen.char_positions.has(cell):
				var cell_height : int = map_gen.terrain_map[cell].height
				if abs(cell_height - char_height) > skill.max_height_difference:
					continue
				var char_node : Character_node = map_gen.char_positions[cell]
				if BattleHandler.allies.has(char_node):
					dir_able[dir] = true
		var move_cells : Array[Vector2i] = skill.skill_map.move_cells.duplicate(true)
		if dir_able[dir] and !move_cells.is_empty():
			for i in move_cells.size():
				move_cells[i] += char_map_pos
			if dir != Map_generator.directions.N:
				move_cells = rotare_skill_cells_around_position(move_cells, char_map_pos, dir)
			for cell in move_cells:
				if map_gen.char_positions.has(cell):
					dir_able[dir] = false
				if !map_gen.map_cells.has(cell):
					dir_able[dir] = false
		if dir_able[dir]:
			var skill_able_data := Skill_able_data.new()
			skill_able_data.skill = skill
			skill_able_data.dir = dir
			skill_able_data.damage_cells = damage_cells
			skill_able_data.used_position = char_map_pos
			skill_able_data.target_cell = map_gen.dir_to_vector[dir] + char_map_pos
			skill_able_data.move_cells = move_cells
			skill_able_data_arr.append(skill_able_data)
			for cell in damage_cells:
				if map_gen.char_positions.has(cell):
					var cell_height : int = map_gen.terrain_map[cell].height
					if abs(cell_height - char_height) > skill.max_height_difference:
						continue
					skill_able_data.targets.append(cell)
					var char_node : Character_node = map_gen.char_positions[cell]
					if BattleHandler.allies.has(char_node):
						skill_able_data.enemy_targets.append(cell)
	return skill_able_data_arr

func rotare_skill_cells_around_position(cells : Array[Vector2i], 
cell_pos : Vector2i, dir : Map_generator.directions) -> Array[Vector2i]:
	var rotated_cells : Array[Vector2i] = []
	for cell in cells:
		var temp_v : Vector2 = cell - cell_pos
		var angle : float = map_gen.dir_to_rad[dir] - map_gen.dir_to_rad[Map_generator.directions.N]
		temp_v = temp_v.rotated(angle)
		var new_cell : Vector2i = cell_pos + Vector2i(round(temp_v.x), round(temp_v.y))
		rotated_cells.append(new_cell)
	return rotated_cells

func can_use_unbound_skill_in_position(skill : Skill_base, 
map_pos : Vector2i, char_height : int, char_current_pos : Vector2i) -> Array[Skill_able_data]:
	var range_cells : Array[Vector2i] = map_gen.get_flow_cells(
		map_pos, skill.max_dist, true, true, skill.max_height_difference, true, false
	)
	var skill_able_data_arr : Array[Skill_able_data] = []
	for range_cell in range_cells:
		#var cell_height : int = map_gen.terrain_map[range_cell].height
		#if abs(cell_height - char_height) > skill.max_height_difference:
			#continue
		for dir in Map_generator.directions.values():
			var damage_cells : Array[Vector2i] = skill.skill_map.damage_cells.duplicate(true)
			for i in damage_cells.size():
				damage_cells[i] += range_cell
			if dir != Map_generator.directions.N:
				damage_cells = rotare_skill_cells_around_position(damage_cells, range_cell, dir)
			var check := false
			for cell in damage_cells:
				if map_gen.char_positions.has(cell):
					var cell_height : int = map_gen.terrain_map[cell].height
					if abs(cell_height - char_height) > skill.max_height_difference:
						continue
					var char_node : Character_node = map_gen.char_positions[cell]
					if BattleHandler.allies.has(char_node):
						check = true
			if check:
				var skill_able_data := Skill_able_data.new()
				skill_able_data.skill = skill
				skill_able_data.dir = dir
				skill_able_data.damage_cells = damage_cells
				skill_able_data.used_position = map_pos
				skill_able_data.target_cell = range_cell
				skill_able_data_arr.append(skill_able_data)
				for cell in damage_cells:
					if map_gen.char_positions.has(cell):
						if cell == char_current_pos and map_pos != char_current_pos:
							continue
						skill_able_data.targets.append(cell)
						var char_node : Character_node = map_gen.char_positions[cell]
						if BattleHandler.allies.has(char_node):
							skill_able_data.enemy_targets.append(cell)
					if cell == map_pos and !skill_able_data.targets.has(cell):
						skill_able_data.targets.append(cell)
	return skill_able_data_arr

func pretend_fire(attacker : Vector3, target : Vector3) -> bool:
	var query := PhysicsRayQueryParameters3D.create(attacker + Vector3(0, 1.5, 0), target + Vector3(0, 1.5, 0))
	query.collide_with_areas = true
	query.collision_mask = 0x0002
	var space_state = ObjectLink.map_gen.get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)
	
	if result.has("collider"):
		return false
	return true

var neighbors_sides : Array[Vector2i] = [
	Vector2i.UP,
	Vector2i.RIGHT,
	Vector2i.DOWN,
	Vector2i.LEFT,
]

var checked_cells : Array[Vector2i] = []
func get_flow_distance(cell : Vector2i, target_cell : Vector2i) -> int:
	checked_cells.clear()
	var border : Array[Vector2i] = [cell]
	var terrain_map : Array[Vector2i] = map_gen.terrain_map.keys()
	var iter := 0
	while true:
		iter += 1
		var new_border : Array[Vector2i] = []
		for b_cell in border:
			for n_c in neighbors_sides:
				var new_cell : Vector2i = n_c + b_cell
				if !terrain_map.has(new_cell):
					continue
				if checked_cells.has(new_cell):
					continue
				if new_border.has(new_cell):
					continue
				new_border.append(new_cell)
			checked_cells.append(b_cell)
		border = new_border
		var check := false
		for b_cell in border:
			if b_cell == target_cell:
				check = true
				break
		if check:
			break
	return iter





#
