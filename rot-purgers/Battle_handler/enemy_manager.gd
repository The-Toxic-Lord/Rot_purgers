extends Node

class_name Enemy_manager

signal enemies_turn_ended

var map_gen : Map_generator
@export var temp : Array[Skill_able_data]

func start_enemy_turn():
	await get_tree().process_frame
	for enemy in BattleHandler.enemies:
		map_gen.set_camera_target(enemy)
		match enemy.stats.AI_type:
			Character_stats.AI_types.TURRET:
				await handle_turret_AI(enemy)
			Character_stats.AI_types.NORMAL:
				await handle_normal_AI(enemy)
			Character_stats.AI_types.CHARGER:
				await handle_charger_AI(enemy)
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
	var a_star := AStarGrid2D.new()
	a_star.region = map_gen.selector_boundary
	a_star.cell_size = Vector2i(1,1)
	a_star.default_compute_heuristic = AStarGrid2D.HEURISTIC_CHEBYSHEV
	a_star.default_estimate_heuristic = AStarGrid2D.HEURISTIC_CHEBYSHEV
	a_star.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	a_star.update()
	
	a_star.fill_solid_region(a_star.region, false)
	a_star.update()
	
	var targets : Array[Character_node] = []
	
	for ally in BattleHandler.allies:
		var path : Array[Vector2i] = a_star.get_id_path(enemy.map_pos, ally.map_pos)
		if path.size() <= enemy.stats.attack_distance + 1 + enemy.stats.move_speed:
			if path.size() <= enemy.stats.attack_distance + 1:
				var height : int = map_gen.terrain_map[ally.map_pos].height
				if abs(height - map_gen.terrain_map[enemy.map_pos].height) < enemy.stats.attack_height:
					BattleHandler.add_attack(enemy, ally)
					return
			targets.append(ally)
	
	var move_cells : Array[Vector2i] = map_gen.get_flow_cells(enemy.map_pos, enemy.stats.move_speed,
	false, true, enemy.stats.jump_height, false)
	for cell in move_cells:
		if map_gen.char_positions.has(cell):
			continue
		for ally in BattleHandler.allies:
			var path : Array[Vector2i] = a_star.get_id_path(cell, ally.map_pos)
			if path.size() <= enemy.stats.attack_distance + 1:
				var height : int = map_gen.terrain_map[ally.map_pos].height
				if abs(height - map_gen.terrain_map[cell].height) < enemy.stats.attack_height:
					BattleHandler.add_attack(enemy, ally)
					map_gen.char_positions.erase(enemy.map_pos)
					enemy.move(cell, map_gen.terrain_map, move_cells, map_gen.selector_boundary, map_gen.map_cells)
					await enemy.move_finished
					await map_gen.update_char_position(enemy, cell)
					return

func handle_charger_AI(enemy : Character_node):
	var move_cells : Array[Vector2i] = map_gen.get_flow_cells(enemy.map_pos, enemy.stats.move_speed,
	false, true, enemy.stats.jump_height, false)
	
	for en in BattleHandler.enemies:
		move_cells.erase(en.map_pos)
	
	var skill_possibilities : Array[Skill_able_data] = []
	for cell in move_cells:
		skill_possibilities.append_array(can_use_skills_in_position(enemy, cell))
	temp = skill_possibilities
	if !skill_possibilities.is_empty():
		# ADD difficulty paths
		# on hight difficulties enemies must evade damage cells in already issued orders
		var max_targets := 0
		var frienly_targets := 0
		var chosen_possibility : Skill_able_data
		for skill_possible in skill_possibilities:
			if max_targets < skill_possible.enemy_targets.size():
				chosen_possibility = skill_possible
				max_targets = skill_possible.enemy_targets.size()
				frienly_targets = skill_possible.targets.size() - max_targets
			elif max_targets == skill_possible.enemy_targets.size() and\
			 frienly_targets < skill_possible.targets.size() - max_targets:
				chosen_possibility = skill_possible
				max_targets = skill_possible.enemy_targets.size()
				frienly_targets = skill_possible.targets.size() - max_targets
		var zero_array : Array[Vector2i] = []
		await move_charger(chosen_possibility.used_position, enemy, move_cells)
		BattleHandler.add_skill(enemy, chosen_possibility.skill, 
		chosen_possibility.damage_cells, zero_array, chosen_possibility.target_cell)
		return
	
	var attack_possibilities : Dictionary[Vector2i, Array] = {}
	for cell in move_cells:
		attack_possibilities[cell] = can_attack_fom_position(enemy.stats.attack_distance, cell)
	
	if !attack_possibilities.is_empty():
		pass
	
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
	for en in BattleHandler.enemies:
		a_star.set_point_solid(en.map_pos, false)
	a_star.update()
	
	var targets : Array[Character_node] = []
	var paths : Array[Array] = []
	
	for neib in neib_side:
		if map_gen.char_positions.has(neib + enemy.map_pos):
			if BattleHandler.allies.has(map_gen.char_positions[neib + enemy.map_pos]):
				var height : int = map_gen.terrain_map[neib + enemy.map_pos].height
				if abs(height - map_gen.terrain_map[enemy.map_pos].height) < enemy.stats.attack_height:
					BattleHandler.add_attack(enemy, map_gen.char_positions[neib + enemy.map_pos])
				return
	
	for ally in BattleHandler.allies:
		a_star.set_point_solid(ally.map_pos, false)
		var new_path : Array[Vector2i] = a_star.get_id_path(enemy.map_pos, ally.map_pos, true)
		if !new_path.is_empty():
			paths.append(new_path)
			targets.append(ally)
		a_star.set_point_solid(ally.map_pos, true)
	
	var skip := false
	for path : Array[Vector2i] in paths:
		if move_cells.has(path[path.size() - 2]):
			await move_charger(path[path.size() - 2], enemy, move_cells)
			skip = true
			break
	
	if !skip:
		for cell in move_cells:
			var bb := false
			if bb:
				break
			for neib in neib_side:
				var t_c : Vector2i = neib + cell
				if map_gen.char_positions.has(t_c):
					if BattleHandler.allies.has(map_gen.char_positions[t_c]) and !skip and !bb:
						await move_charger(cell, enemy, move_cells)
						skip = true
						bb = true
						break
	
	if !skip and !paths.is_empty():
		var id : int = 0
		for i in paths.size():
			if paths[i].size() < paths[id].size() and !map_gen.char_positions.keys().has(paths[i][enemy.stats.move_speed]):
				id = i
		for en in BattleHandler.enemies:
			a_star.set_point_solid(en.map_pos, true)
		a_star.set_point_solid(targets[id].map_pos, true)
		for cell in move_cells:
			a_star.set_point_solid(cell, false)
		a_star.set_point_solid(enemy.map_pos, false)
		var path : Array[Vector2i] = a_star.get_id_path(enemy.map_pos, targets[id].map_pos, true)
		if path.is_empty() or path.size() == 1:
			return
		var cell : Vector2i
		if path.size() >= enemy.stats.move_speed + 1:
			cell = path[enemy.stats.move_speed]
		else:
			cell = path.back()
		await move_charger(cell, enemy, move_cells)
	
	for neib in neib_side:
		if map_gen.char_positions.has(neib + enemy.map_pos):
			if BattleHandler.allies.has(map_gen.char_positions[neib + enemy.map_pos]):
				var height : int = map_gen.terrain_map[neib + enemy.map_pos].height
				if abs(height - map_gen.terrain_map[enemy.map_pos].height) < enemy.stats.attack_height:
					BattleHandler.add_attack(enemy, map_gen.char_positions[neib + enemy.map_pos])

var neib_side : Array[Vector2i] = [
	Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT
]

func move_charger(cell : Vector2i, enemy : Character_node, move_cells : Array[Vector2i]):
	map_gen.char_positions.erase(enemy.map_pos)
	enemy.move(cell,map_gen.terrain_map, 
			move_cells, map_gen.selector_boundary,map_gen.map_cells)
	await enemy.move_finished
	await map_gen.update_char_position(enemy, enemy.map_pos)


func can_attack_fom_position(attack_distance : int, position_cell : Vector2i) -> Array[Vector2i]:
	var range_cells : Array[Vector2i] = map_gen.get_flow_cells(position_cell, attack_distance)
	var targers : Array[Vector2i] = []
	for cell in range_cells:
		if map_gen.char_positions.has(cell):
			var char_node : Character_node = map_gen.char_positions[cell]
			if BattleHandler.allies.has(char_node):
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
			skills_able_data.append_array(can_use_unbound_skill_in_position(skill, position_cell))
	return skills_able_data

func can_use_bound_skill_in_position(skill : Skill_base, 
char_map_pos : Vector2i) -> Array[Skill_able_data]:
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
				var char_node : Character_node = map_gen.char_positions[cell]
				if BattleHandler.allies.has(char_node):
					dir_able[dir] = true
		if dir_able[dir]:
			var move_cells : Array[Vector2i] = skill.skill_map.move_cells.duplicate(true)
			if !move_cells.is_empty():
				for i in move_cells.size():
					move_cells[i] += char_map_pos
				if dir != Map_generator.directions.N:
					move_cells = rotare_skill_cells_around_position(move_cells, char_map_pos, dir)
				for cell in move_cells:
					if map_gen.char_positions.has(cell):
						dir_able[dir] = false
		if dir_able[dir]:
			var skill_able_data := Skill_able_data.new()
			skill_able_data.skill = skill
			skill_able_data.dir = dir
			skill_able_data.damage_cells = damage_cells
			skill_able_data.used_position = char_map_pos
			skill_able_data.target_cell = map_gen.dir_to_vector[dir] + char_map_pos
			skill_able_data_arr.append(skill_able_data)
			for cell in damage_cells:
				if map_gen.char_positions.has(cell):
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

func can_use_unbound_skill_in_position(skill : Skill_base, map_pos : Vector2i) -> Array[Skill_able_data]:
	var range_cells : Array[Vector2i] = map_gen.get_flow_cells(
		map_pos, skill.max_dist
	)
	var skill_able_data_arr : Array[Skill_able_data] = []
	for range_cell in range_cells:
		for dir in Map_generator.directions.values():
			var damage_cells : Array[Vector2i] = skill.skill_map.damage_cells.duplicate(true)
			for i in damage_cells.size():
				damage_cells[i] += range_cell
			if dir != Map_generator.directions.N:
				damage_cells = rotare_skill_cells_around_position(damage_cells, range_cell, dir)
			var check := false
			for cell in damage_cells:
				if map_gen.char_positions.has(cell):
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
						skill_able_data.targets.append(cell)
						var char_node : Character_node = map_gen.char_positions[cell]
						if BattleHandler.allies.has(char_node):
							skill_able_data.enemy_targets.append(cell)
	return skill_able_data_arr







#
