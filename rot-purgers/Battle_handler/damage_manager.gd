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
	if hit_check(target, attacker):
		var damage : float
		if target.is_defending:
			damage = attacker.stats.strength - target.stats.defence
		else:
			damage = attacker.stats.strength - (float(target.stats.defence) / 2)
		if damage < 0:
			damage = 0
		await target.damage(damage)
	else:
		pass
		# ADD miss
	await get_tree().process_frame
	order_ended.emit()

func skill_mass(order : Order_skill_data):
	await get_tree().process_frame
	var attacker : Character_node = get_node(order.attacker)
	
	for cell in order.damage_cells:
		if map_gen.char_positions.has(cell):
			await skill_damage(map_gen.char_positions[cell], attacker, order.skill)
	
	order_ended.emit()

func skill_oneshot(order : Order_skill_data):
	await get_tree().process_frame
	var targets : Array[Character_node] = []
	for cell in order.damage_cells:
		if map_gen.char_positions.has(cell):
			targets.append(map_gen.char_positions[cell])
	
	var attacker : Character_node = get_node(order.attacker)
	for target in targets:
		await skill_damage(target, attacker, order.skill)
	
	order_ended.emit()

func skill_damage(target : Character_node, attacker : Character_node, skill : Skill_base):
	if hit_check(target, attacker, skill.accuracy_modifier):
		var damage := skill.damage
		damage *= float(skill.get_stat_used(attacker.stats)) -\
			(float(target.stats.magic_strenght)/2) * (float(target.stats.magic)/target.stats.max_magic)
		if damage < 0.0:
			damage = 0.0
		await target.damage(damage)
	else:
		pass
		# ADD miss

func heal(order : Order_heal):
	await get_tree().process_frame
	var attacker : Character_node = get_node(order.attacker)
	attacker.heal(order.skill.heal_value)
	order_ended.emit()








#
