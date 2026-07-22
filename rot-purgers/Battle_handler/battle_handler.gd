extends Node

class_name Battle_handler

enum states { PLAYER, ENEMY, ANIMATION }
var state : states = states.PLAYER
var prev_state : states

var map_gen : Map_generator

var allies : Array[Character_node] = []
var enemies : Array[Character_node] = []

@onready var dmg_mng : Damage_manager = $Damage_manager
var attack_array : Array[Attack_data] = []

@onready var en_mng : Enemy_manager = $Enemy_manager

signal attack_handled
signal orders_executed

func new_battle_start():
	state = states.PLAYER
	allies = []
	enemies = []
	attack_array = []

func add_attack(attacker : Character_node, target : Character_node):
	var attack_data := Attack_data.new(attacker, target)
	attack_array.append(attack_data)

func handle_attack(attack_data : Attack_data):
	await get_tree().process_frame
	if has_node(attack_data.target) and has_node(attack_data.attacker):
		var target : Character_node = get_node(attack_data.target)
		var attacker : Character_node = get_node(attack_data.attacker)
		dmg_mng.attack_damage(target, attacker)
		await dmg_mng.attack_ended
	attack_handled.emit()

func execute_orders():
	prev_state = state
	state = states.ANIMATION
	for attack_data in attack_array:
		map_gen.move_camera(get_node(attack_data.attacker))
		handle_attack(attack_data)
		await attack_handled
	attack_array.clear()
	state = prev_state
	orders_executed.emit()

func end_player_turn():
	state = states.ENEMY
	if !attack_array.is_empty():
		execute_orders()
		await orders_executed
	en_mng.start_enemy_turn()
	await en_mng.enemies_turn_ended
	start_player_turn()

func start_player_turn():
	for ch in allies:
		ch.end_round()
	state = states.PLAYER
	map_gen.freze_selector = false

func enemy_dies(enemy : Character_node):
	enemies.erase(enemy)
	map_gen.remove_enemy(enemy)
	if enemies.is_empty():
		print("Victory!")

func start_animation_freeze():
	prev_state = state
	state = states.ANIMATION

func stop_animation_freeze():
	state = prev_state






#
