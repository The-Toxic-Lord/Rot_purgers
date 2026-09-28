@tool
extends Node

class_name Stats_calculator

enum difficulyties { EASY, NORMAL, HARD }
@export var allies : Array[Character_stats]
@export var difficulty : difficulyties = difficulyties.NORMAL

@export var diff_dicts : Dictionary[difficulyties, Dictionary] = {
	difficulyties.NORMAL : {
		"hit_chance" : 0.8,
		"get_hit_chance" : 1.0,
		"num_turns_kill" : 5,
		"num_turns_dead" : 2
	}
}

@export var use_magic_str := false

@export_tool_button("Calculate_stats") var bt_1 = calculate_stats

var used_stats : Array[String] = [
	"max_health", "max_magic", "strength", "magic_strenght",
"defence", "accuracy", "speed"
]

@export var health : int
@export var defence : int:
	set(value):
		defence = value
		recalc_def_hp()


@export var enemy_stats : Character_stats
@export var medium_stats : Character_stats

func calculate_stats():
	medium_stats = Character_stats.new()
	medium_stats.name = "enemy"
	for stat in used_stats:
		medium_stats.set(stat, 0)
	for ally in allies:
		for stat in used_stats:
			medium_stats.set(stat, medium_stats.get(stat) + ally.get(stat))
	for stat in used_stats:
		medium_stats.set(stat, roundi(medium_stats.get(stat) / allies.size()))
	
	enemy_stats = Character_stats.new()
	var diff_dict = diff_dicts[difficulty]
	enemy_stats.accuracy = get_acc(medium_stats, diff_dict["hit_chance"])
	enemy_stats.speed = get_speed(medium_stats, diff_dict["get_hit_chance"])
	enemy_stats.strength = get_str(medium_stats, diff_dict["hit_chance"], diff_dict["num_turns_kill"])
	enemy_stats.defence = 0
	health = enemy_stats.max_health
	defence = 0

func calc_hit_chance(target : Character_stats, attacker : Character_stats) -> float:
	var chance = float(attacker.accuracy)/float(target.speed)
	return chance

func get_acc(med_st : Character_stats, hit_chance : float) -> int:
	return roundi(med_st.speed * hit_chance)

func get_speed(med_st : Character_stats, hit_chance : float) -> int:
	return roundi(med_st.accuracy / hit_chance)

func get_str(med_st : Character_stats, hit_chance : float, num_of_turns : int) -> int:
	var damage : float = med_st.max_health as float / num_of_turns
	if hit_chance < 1.0:
		damage /= hit_chance
	damage += med_st.defence / 2.0
	return roundi(damage)

func get_def(med_st : Character_stats, hit_chance : float, num_of_turns : int) -> int:
	var damage : float = med_st.strength * num_of_turns
	if hit_chance < 1.0:
		damage *= hit_chance
	if damage <= enemy_stats.max_health:
		return 10
	else:
		var def : float = damage - enemy_stats.max_health
		def /= num_of_turns
		def *= 2
		return roundi(def)

func recalc_def_hp():
	enemy_stats.defence = defence
	var damage : float = medium_stats.strength - defence / 2.0
	var damage_skill : float = medium_stats.magic_strenght * 1.5 - defence / 2.0
	if use_magic_str:
		health = diff_dicts[difficulty]["num_turns_dead"] * damage_skill
		enemy_stats.max_health = health
	else:
		health = diff_dicts[difficulty]["num_turns_dead"] * damage
		enemy_stats.max_health = health





#
