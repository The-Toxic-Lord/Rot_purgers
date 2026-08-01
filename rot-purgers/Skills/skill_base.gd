@tool
extends Resource

class_name Skill_base

@export var name := ""
@export_multiline var desctiption : String
@export var magic_cost : int = 0

@export var skill_map : Skill_map_data

@export var is_attack := false:
	set(value):
		is_attack = value
		notify_property_list_changed()
@export var damage : float
@export var max_height_difference : int = 10
@export var max_dist : int = 1
@export var accuracy_modifier : float = 0.0
@export var crit_chance : float = 0.05
@export var stat_used : Character_stats.stats = Character_stats.stats.magic_strenght
@export var defence_stat : Character_stats.stats = Character_stats.stats.magic_strenght
@export var animation_jump : bool = false

@export var is_heal := false:
	set(value):
		is_heal = value
		notify_property_list_changed()
@export var heal_value : float

func _validate_property(property: Dictionary) -> void:
	if property.name in ["damage", "max_height_difference", "max_dist",
	"accuracy_modifier", "crit_chance", "stat_used", "defence_stat", "animation_jump"]:
		if !is_attack:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name in ["heal_value"]:
		if !is_heal:
			property.usage = PROPERTY_USAGE_NO_EDITOR

func get_attack_stat_used(st : Character_stats) -> int:
	return st.get(Character_stats.stats.keys()[stat_used])

func get_defence_stat_used(st : Character_stats) -> int:
	return st.get(Character_stats.stats.keys()[defence_stat])











#
