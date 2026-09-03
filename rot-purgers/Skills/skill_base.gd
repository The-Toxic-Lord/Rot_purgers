@tool
extends Resource

class_name Skill_base

@export var name := ""
@export_multiline var desctiption : String
@export var magic_cost : int = 0

@export var skill_map : Skill_map_data

enum skill_types { ATTACK, HEAL, TERRAIN, PROTECT, SPAWN }
@export var skill_type : skill_types = skill_types.ATTACK:
	set(value):
		skill_type = value
		notify_property_list_changed()

@export var damage : float
@export var is_one_shot := true
@export var max_height_difference : int = 10
@export var max_dist : int = 1
@export var accuracy_modifier : float = 0.0
@export var crit_chance : float = 0.05
@export var stat_used : Character_stats.stats = Character_stats.stats.magic_strenght
@export var defence_stat : Character_stats.stats = Character_stats.stats.magic_strenght
@export var animation_jump : bool = false
@export var can_be_deflected : bool = false
#ADD @export var animation_name : String

enum move { NONE, SELF, TARGET }
@export var move_mode : move = move.NONE

@export var deflect_times : int = 1

@export var heal_value : float

enum terrain_mods { MOVE, HEIGHT }
@export var terrain_mod : terrain_mods = terrain_mods.HEIGHT

@export var spawn_node_UUID : String

func _validate_property(property: Dictionary) -> void:
	if property.name in ["damage", "is_one_shot", "move_mode", "can_be_deflected",
	"accuracy_modifier", "crit_chance", "stat_used", "defence_stat", "animation_jump"]:
		if skill_type != skill_types.ATTACK:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name in ["heal_value"]:
		if skill_type != skill_types.HEAL:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name == "max_dist":
		if skill_type == skill_types.HEAL:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name == "max_height_difference":
		if skill_type != skill_types.ATTACK and skill_type != skill_types.PROTECT:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name in ["terrain_mod"]:
		if skill_type != skill_types.TERRAIN:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name == "deflect_times":
		if skill_type != skill_types.PROTECT:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name == "spawn_node_UUID":
		if skill_type != skill_types.SPAWN:
			property.usage = PROPERTY_USAGE_NO_EDITOR

func get_attack_stat_used(st : Character_stats) -> int:
	return st.get(Character_stats.stats.keys()[stat_used])

func get_defence_stat_used(st : Character_stats) -> int:
	return st.get(Character_stats.stats.keys()[defence_stat])











#
