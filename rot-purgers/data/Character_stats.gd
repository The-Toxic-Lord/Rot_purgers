@tool extends Resource

class_name Character_stats

enum stats { max_health, health, max_magic, magic, strength, 
defence, magic_strenght, accuracy, speed, jump_height, move_speed }

@export_group("visual")
@export var name := "rename me"
@export var char_class := "class"
@export var age := 20
@export var sprite : Texture2D

@export_group("stats")
@export var max_health := 100
@export_storage var health : int
@export var max_magic := 100
@export_storage var magic : int
@export var strength : int = 10
@export var defence : int = 5
@export var magic_strenght : int = 10
@export var accuracy : int = 10
@export var speed : int = 5
@export var attack_stat : stats = stats.strength
@export var defender_stat : stats = stats.defence

func get_stat(stat : stats) -> int:
	return get(stats.keys()[stat])

func set_stat(stat : stats, value : int):
	set(stats.keys()[stat], value)

func get_attack_stat_used() -> int:
	return get(stats.keys()[attack_stat])

func get_defence_stat(st : stats):
	return get(stats.keys()[st])

@export_group("randstats")
@export var move_speed : int = 4
@export var jump_height : int = 20
@export var attack_distance : int = 1
@export var attack_height : int = 10
@export var counter : int = 1
@export_group("", "")
@export var node_UID : String
@export var start_dir : Map_generator.directions

enum AI_types { TURRET, NORMAL, CHARGER, MEATWALL, SPAWNER }
@export var AI_type : AI_types = AI_types.NORMAL:
	set(value):
		AI_type = value
		notify_property_list_changed()

@export var skills : Array[Skill_base]
@export var potential_skills : Array[Skill_base]
@export_storage var atlas_coords : Vector2i

@export var spawn_node_UUID : String

func new() -> void:
	health = max_health
	magic = max_magic

enum adjust_stats { max_health, strength, defence, accuracy, speed }

func stats_adjust():
	var magic_mod : float
	var map_magic_mod : float = GlobalData.map_magic_cost_adjustment
	if map_magic_mod <= 2.0:
		magic_mod = 1.2 - (map_magic_mod - 1.0) * 0.2
	else:
		magic_mod = 1.0 - (map_magic_mod - 2.0) * 0.2
	for st in adjust_stats:
		if st in ["accuracy", "speed", "max_health"]:
			set(st, snapped(int(get(st) * magic_mod), 5))
		else:
			set(st, int(get(st) * magic_mod))
	health = max_health
	magic = max_magic

var readjust_points : int = 0

func _validate_property(property: Dictionary) -> void:
	if property.name in ["spawn_node_UUID"]:
		if AI_type != AI_types.SPAWNER:
			property.usage = PROPERTY_USAGE_NO_EDITOR




#
