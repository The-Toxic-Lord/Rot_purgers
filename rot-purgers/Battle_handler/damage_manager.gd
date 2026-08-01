extends Node

class_name Damage_manager

var map_gen : Map_generator

signal order_ended

func hit_check(target : Character_node, attacker : Character_node, acc_mod : float = 0.0) -> bool:
	var chance = pow(float(attacker.stats.accuracy)/float(target.stats.speed),2) + acc_mod
	if randf_range(0, 1) < chance:
		return true
	else:
		return false

func attack_damage(target : Character_node, attacker : Character_node):
	attacker.attack(target.map_pos)
	await attacker.attack_finished
	if hit_check(target, attacker):
		var damage : float = attacker.stats.get_attack_stat_used()
		if target.is_defending:
			damage -= target.stats.get_defence_stat(attacker.stats.defender_stat)
		else:
			damage -= (float(target.stats.get_defence_stat(attacker.stats.defender_stat)) / 2)
		if damage < 0:
			damage = 0
		await target.damage(damage)
	else:
		await target.damage(-1)
	map_gen.set_camera_target(target)
	map_gen.set_selector(target.map_pos)
	await target.animation_ended
		# ADD miss
	await get_tree().process_frame
	order_ended.emit()

func skill_mass(order : Order_skill_data):
	await get_tree().process_frame
	var attacker : Character_node = get_node(order.attacker)
	if map_gen.map_data != null:
		attacker.magic_cost(int(order.skill.magic_cost * map_gen.map_data.magic_cost_adjustment))
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
		for target in target_damage.keys():
			target.damage(target_damage[target])
		await target_damage.keys()[0].animation_ended
	
	order_ended.emit()

func skill_oneshot(order : Order_skill_data):
	await get_tree().process_frame
	var targets : Array[Character_node] = []
	for cell in order.damage_cells:
		if map_gen.char_positions.has(cell):
			targets.append(map_gen.char_positions[cell])
	var attacker : Character_node = get_node(order.attacker)
	if map_gen.map_data != null:
		attacker.magic_cost(int(order.skill.magic_cost * map_gen.map_data.magic_cost_adjustment))
	else:
		attacker.magic_cost(int(order.skill.magic_cost))
	map_gen.set_selector(attacker.map_pos)
	attacker.skill(order.selected_cell, order.skill.animation_jump)
	await attacker.attack_finished
	var target_damage : Dictionary[Character_node, float] = {}
	for target in targets:
		target_damage[target] = skill_damage(target, attacker, order.skill)
	for target in targets:
		target.damage(target_damage[target])
	if !targets.is_empty():
		await targets[0].animation_ended
	
	order_ended.emit()

func skill_damage(target : Character_node, attacker : Character_node, skill : Skill_base) -> float:
	if hit_check(target, attacker, skill.accuracy_modifier):
		var damage := skill.damage
		#print(float(skill.get_attack_stat_used(attacker.stats)) -\
			#(float(skill.get_defence_stat_used(target.stats))/2))
		#print(float(skill.get_attack_stat_used(attacker.stats)))
		#print(skill.get_defence_stat_used(target.stats))
		damage *= float(skill.get_attack_stat_used(attacker.stats))
		damage -= float(skill.get_defence_stat_used(target.stats)) / 2
		if damage < 0.0:
			damage = 0.0
		return damage
	else:
		return -1

func heal(order : Order_heal):
	await get_tree().process_frame
	var attacker : Character_node = get_node(order.attacker)
	attacker.magic_cost(int(order.skill.magic_cost * map_gen.map_data.magic_cost_adjustment))
	attacker.heal(order.skill.heal_value)
	await attacker.animation_ended
	order_ended.emit()








#
