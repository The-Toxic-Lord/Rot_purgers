extends Node

class_name Damage_manager

signal attack_ended

func hit_check(target : Character_node, attacker : Character_node, acc_mod : float) -> bool:
	var chance = pow(float(attacker.stats.accuracy)/float(target.stats.speed),2) + acc_mod
	if randf_range(0, 1) < chance:
		return true
	else:
		return false

func attack_damage(target : Character_node, attacker : Character_node):
	if hit_check(target, attacker, 0.0):
		var damage : float =  attacker.stats.strength - (float(target.stats.defence) / 2)
		if damage < 0:
			damage = 0
		await target.damage(damage)
	else:
		pass
		# ADD miss
	await get_tree().process_frame
	attack_ended.emit()
