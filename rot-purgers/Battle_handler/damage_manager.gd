extends Node

class_name Damage_manager

var map_gen : Map_generator

signal order_ended

enum hit_types { MISS, NORMAL, NICK, BULLSEYE }

func calc_hit_chance(target : Character_node, attacker : Character_node, acc_mod : float = 0.0) -> float:
	var chance = float(attacker.stats.accuracy)/float(target.stats.speed) + acc_mod
	return chance

func calc_hit_type(chance : float) -> hit_types:
	if chance >= 1.0:
		if randf() < chance - 1.0:
			return hit_types.BULLSEYE
		else:
			return hit_types.NORMAL
	elif randf() < chance:
		return hit_types.NORMAL
	elif randf() < chance:
		return hit_types.NICK
	else:
		return hit_types.MISS

func deflect_check(target : Character_node, attacker : Character_node) -> bool:
	var points : Array[Vector2i] = Geometry2D.bresenham_line(attacker.map_pos, target.map_pos)
	var closest_char : Character_node
	var closest_cell : Vector2i
	for char_node in BattleHandler.protected_cells:
		var cells : Array[Vector2i] = BattleHandler.protected_cells[char_node]
		for v in points:
			if !cells.has(v):
				continue
			@warning_ignore("unassigned_variable")
			if closest_char == null:
				closest_cell = v
				closest_char = char_node
				continue
			if (v - attacker.map_pos).length_squared() <\
			 (closest_cell - attacker.map_pos).length_squared():
				closest_cell = v
				closest_char = char_node
	if closest_char != null:
		closest_char.deflects_left -= 1
		if closest_char.deflects_left == 0:
			BattleHandler.protected_cells.erase(closest_char)
		return true
	return false

func attack_damage(target : Character_node, attacker : Character_node):
	attacker.attack(target.map_pos)
	await attacker.attack_finished
	#if (target.map_pos - attacker.map_pos).length() > 1:
	if deflect_check(target, attacker):
		order_ended.emit()
		return
	map_gen.set_camera_target(target)
	map_gen.set_selector(target.map_pos)
	await get_tree().process_frame
	var hit_chance : float = calc_hit_chance(target, attacker)
	var hit_type : hit_types = calc_hit_type(hit_chance)
	match hit_type:
		hit_types.MISS:
			await target.damage(-1)
		_:
			var damage : float = attacker.stats.get_attack_stat_used()
			match hit_type:
				hit_types.NICK:
					print("nick")
					damage *= 0.5
				hit_types.BULLSEYE:
					print("bullseye")
					damage *= 1.5
			if target.is_defending:
				damage -= target.stats.get_defence_stat(attacker.stats.defender_stat)
			else:
				damage -= (float(target.stats.get_defence_stat(attacker.stats.defender_stat)) / 2)
			if damage < 0:
				damage = 0
			await target.damage(damage, true)
	await target.animation_ended
	await get_tree().process_frame
	order_ended.emit()

func skill_mass(order : Order_skill_data):
	await get_tree().process_frame
	var attacker : Character_node = get_node(order.attacker)
	if map_gen.map_data != null:
		attacker.magic_cost(int(order.skill.magic_cost * GlobalData.map_magic_cost_adjustment))
	else:
		attacker.magic_cost(int(order.skill.magic_cost))
	map_gen.set_selector(attacker.map_pos)
	attacker.skill(order.selected_cell, order.skill.animation_jump)
	await attacker.attack_finished
	var target_damage : Dictionary[Character_node, float] = {}
	for cell in order.damage_cells:
		if map_gen.char_positions.has(cell):
			target_damage[map_gen.char_positions[cell]] = \
			skill_damage(map_gen.char_positions[cell], attacker, order.skill)
	if !target_damage.is_empty():
		for target : Character_node in target_damage.keys():
			map_gen.set_camera_target(target)
			map_gen.set_selector(target.map_pos)
			target.damage(target_damage[target], true)
			await target.animation_ended
		#await target_damage.keys()[0].animation_ended
		await get_tree().process_frame
		while true:
			var dead_check := true
			for target in target_damage.keys():
				if target != null:
					if target.is_dead:
						dead_check = false
			if dead_check:
				break
	
	order_ended.emit()

func skill_oneshot(order : Order_skill_data):
	await get_tree().process_frame
	var targets : Array[Character_node] = []
	for cell in order.damage_cells:
		if map_gen.char_positions.has(cell):
			targets.append(map_gen.char_positions[cell])
	var attacker : Character_node = get_node(order.attacker)
	if order.skill.can_be_deflected:
		for target in targets:
			if deflect_check(target, attacker):
				order_ended.emit()
				return
	if map_gen.map_data != null:
		attacker.magic_cost(int(order.skill.magic_cost * GlobalData.map_magic_cost_adjustment))
	else:
		attacker.magic_cost(int(order.skill.magic_cost))
	map_gen.set_selector(attacker.map_pos)
	attacker.skill(order.selected_cell, order.skill.animation_jump)
	await attacker.attack_finished
	var target_damage : Dictionary[Character_node, float] = {}
	await handle_skill_movement(order, attacker, targets[0])
	for target in targets:
		target_damage[target] = skill_damage(target, attacker, order.skill)
	for target in targets:
		target.damage(target_damage[target])
	if !targets.is_empty():
		await targets[0].animation_ended
		await get_tree().process_frame
		while true:
			var dead_check := true
			for target in targets:
				if target != null:
					if target.is_dead:
						dead_check = false
			if dead_check:
				break
	
	
	order_ended.emit()

func skill_damage(target : Character_node, attacker : Character_node, skill : Skill_base) -> float:
	var hit_chance : float = calc_hit_chance(target, attacker)
	var hit_type : hit_types = calc_hit_type(hit_chance)
	match hit_type:
		hit_types.MISS:
			return -1
		_:
			var damage := 0.0
			damage += float(skill.get_attack_stat_used(attacker.stats))
			damage -= float(skill.get_defence_stat_used(target.stats)) / 2
			damage *= skill.damage
			if damage < 0.0:
				damage = 0.0
			return damage

func heal(order : Order_heal):
	await get_tree().process_frame
	var attacker : Character_node = get_node(order.attacker)
	attacker.magic_cost(int(order.skill.magic_cost * GlobalData.magic_cost_adjustment))
	attacker.heal(order.skill.heal_value)
	await attacker.animation_ended
	order_ended.emit()

func handle_skill_movement(order : Order_skill_data, 
attacker : Character_node, target : Character_node):
	#attacker.position = map_gen.map_cells[order.move_cells[0]].position
	match order.skill.move_mode:
		Skill_base.move.SELF:
			map_gen.teleport_char(attacker, order.move_target)
		Skill_base.move.TARGET:
			map_gen.teleport_char(target, order.move_target)
	






#
