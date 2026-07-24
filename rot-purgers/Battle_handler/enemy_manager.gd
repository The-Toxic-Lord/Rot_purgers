extends Node

class_name Enemy_manager

signal enemies_turn_ended

var map_gen : Map_generator

func start_enemy_turn():
	await get_tree().process_frame
	for enemy in BattleHandler.enemies:
		await handle_normal_AI(enemy)
	if !BattleHandler.order_array.is_empty():
		BattleHandler.execute_orders()
		await BattleHandler.orders_executed
	end_enemy_turn()

func end_enemy_turn():
	enemies_turn_ended.emit()

func handle_turret_AI(enemy : Character_node):
	var target_cells : Array[Vector2i] = map_gen.get_flow_cells(enemy.map_pos, enemy.stats.attack_distance,
	true, true, enemy.stats.attack_height)
	var targets : Array[Character_node] = []
	for cell in target_cells:
		if map_gen.char_positions.has(cell):
			var new_target : Character_node = map_gen.char_positions[cell]
			if BattleHandler.allies.has(new_target):
				targets.append(new_target)
	if targets.is_empty():
		return
	var target : Character_node = targets.pick_random()
	BattleHandler.add_attack(enemy, target)

func handle_normal_AI(enemy : Character_node):
	var a_star := AStarGrid2D.new()
	a_star.region = map_gen.selector_boundary
	a_star.cell_size = Vector2i(1,1)
	a_star.default_compute_heuristic = AStarGrid2D.HEURISTIC_CHEBYSHEV
	a_star.default_estimate_heuristic = AStarGrid2D.HEURISTIC_CHEBYSHEV
	a_star.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	a_star.update()
	
	a_star.fill_solid_region(a_star.region, false)
	#for cell in map_gen.terrain_map.keys():
		#if map_gen.terrain_map[cell].passable:
			#a_star.set_point_solid(cell, false)
	#for cell in map_gen.object_map.keys():
		#if !map_gen.object_map[cell].passable:
			#a_star.set_point_solid(cell, true)
	#for ally in BattleHandler.allies:
		#a_star.set_point_solid(ally.map_pos, true)
	a_star.update()
	
	var targets : Array[Character_node] = []
	
	for ally in BattleHandler.allies:
		var path : Array[Vector2i] = a_star.get_id_path(enemy.map_pos, ally.map_pos)
		if path.size() <= enemy.stats.attack_distance + 1 + enemy.stats.move_speed:
			if path.size() <= enemy.stats.attack_distance + 1:
				var height : int = map_gen.terrain_map[ally.map_pos].height
				if height - map_gen.terrain_map[enemy.map_pos].height < enemy.stats.attack_height:
					BattleHandler.add_attack(enemy, ally)
					return
			targets.append(ally)
	
	var move_cells : Array[Vector2i] = map_gen.get_flow_cells(enemy.map_pos, enemy.stats.move_speed,
	false, true, enemy.stats.jump_height, false)
	for cell in move_cells:
		for ally in BattleHandler.allies:
			var path : Array[Vector2i] = a_star.get_id_path(cell, ally.map_pos)
			if path.size() <= enemy.stats.attack_distance + 1:
				var height : int = map_gen.terrain_map[ally.map_pos].height
				if height - map_gen.terrain_map[enemy.map_pos].height < enemy.stats.attack_height:
					BattleHandler.add_attack(enemy, ally)
					enemy.move(cell, map_gen.terrain_map, move_cells, map_gen.selector_boundary, map_gen.map_cells)
					await enemy.move_finished
					map_gen.update_char_position(enemy, cell)
					return








#
