@tool
extends Resource

class_name Skill_base

@export var name := ""
@export_multiline var desctiption : String
@export var magic_cost : int = 0

@export var skill_map : Skill_map_data

var is_attack := false
var damage : float
var max_height_difference : int = 10
var max_dist : int = 1
var accuracy_modifier : float = 0.0
var crit_chance : float = 0.05
var stat_used : Character_stats.stats = Character_stats.stats.magic_strenght

func attack_show_prop(ret : Array[Dictionary]) -> Array[Dictionary]:
	
	ret.append({
		"name": "Damage",
		"type": TYPE_FLOAT
	})
	
	ret.append({
		"name": "Maximum height difference",
		"type": TYPE_INT
	})
	
	ret.append({
		"name": "Maximum distance",
		"type": TYPE_INT
	})
	
	ret.append({
		"name": "Accuracy modifier",
		"type": TYPE_FLOAT
	})
	
	ret.append({
		"name": "Crit chance",
		"type": TYPE_FLOAT
	})
	
	ret.append({
		"name": "Stat used",
		"type": typeof(stat_used),
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "level, max_health, health, max_magic, magic, strength, defence, magic_strenght, accuracy, speed"
	})
	return ret

func get_stat_used(st : Character_stats) -> int:
	return st.get(Character_stats.stats.keys()[stat_used])

var is_heal := false
var heal_value : int

func _get_property_list() -> Array[Dictionary]:
	var ret: Array[Dictionary] = []
	
	ret.append({
		"name": "Is Attack",
		"type": TYPE_BOOL
	})
	
	ret.append({
		"name": "Is Heal",
		"type": TYPE_BOOL
	})
	
	if is_attack:
		attack_show_prop(ret)
	
	if is_heal:
		ret.append({
				"name": "Heal value",
				"type": TYPE_INT
			})
	
	return ret


func _set(prop_name: StringName, val) -> bool:
	# Assume the property exists
	var retval: bool = true
	match prop_name:
		"Heal value":
			heal_value = val
		"Damage":
			damage = val
		"Accuracy modifier":
			accuracy_modifier = val
		"Crit chance":
			crit_chance = val
		"Stat used":
			stat_used = val
		"Is Attack":
			is_attack = val
			notify_property_list_changed()
		"Is Heal":
			is_heal = val
			notify_property_list_changed()
		"Maximum height difference":
			max_height_difference = val
		"Maximum distance":
			max_dist = val
	return retval

func _get(prop_name: StringName):
	match prop_name:
		"Heal value":
			return heal_value
		"Damage":
			return damage
		"Accuracy modifier":
			return accuracy_modifier
		"Crit chance":
			return crit_chance
		"Stat used":
			return stat_used
		"Is Attack":
			return is_attack
		"Is Heal":
			return is_heal
		"Maximum height difference":
			return max_height_difference
		"Maximum distance":
			return max_dist
	return null
