extends Node

class_name Battle_handler

enum states { PLAYER, ENEMY, ANIMATION }
var state : states = states.PLAYER
var prev_state : states

var map_gen : Map_generator

var allies : Array[Character_node] = []
var enemies : Array[Character_node] = []

@onready var dmg_mng : Damage_manager = $Damage_manager
var order_array : Array[Order_data] = []

@onready var en_mng : Enemy_manager = $Enemy_manager

signal order_handled
signal orders_executed

func new_battle_start():
	dmg_mng.map_gen = map_gen
	state = states.PLAYER
	allies = []
	enemies = []
	order_array = []

func add_attack(attacker : Character_node, target : Character_node):
	var order_data := Order_data.new(attacker, target)
	order_array.append(order_data)

func add_skill(attacker : Character_node, skill : Skill_base, 
damage_cells : Array[Vector2i], move_cells : Array[Vector2i]):
	var order := Order_skill_data.new(attacker, skill, damage_cells, move_cells)
	order_array.append(order)

func add_heal(attacker : Character_node, skill : Skill_base):
	var order := Order_heal.new(attacker, skill)
	order_array.append(order)

func handle_attack(order_data : Order_data):
	await get_tree().process_frame
	if has_node(order_data.target) and has_node(order_data.attacker):
		var target : Character_node = get_node(order_data.target)
		var attacker : Character_node = get_node(order_data.attacker)
		dmg_mng.attack_damage(target, attacker)
		await dmg_mng.order_ended
	free_char_from_order(order_data)
	order_handled.emit()

func execute_orders():
	prev_state = state
	state = states.ANIMATION
	for order_data in order_array:
		map_gen.move_camera(get_node(order_data.attacker))
		if order_data is Order_skill_data:
			handle_skill(order_data)
		elif order_data is Order_heal:
			handle_heal(order_data)
		else:
			handle_attack(order_data)
		await order_handled
	order_array.clear()
	state = prev_state
	orders_executed.emit()

func end_player_turn():
	state = states.ENEMY
	if !order_array.is_empty():
		execute_orders()
		await orders_executed
	en_mng.start_enemy_turn()
	await en_mng.enemies_turn_ended
	start_player_turn()

func start_player_turn():
	for ch in allies:
		ch.new_round()
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

func handle_skill(order : Order_skill_data):
	await get_tree().process_frame
	if has_node(order.attacker):
		for cell in order.move_cells:
			if map_gen.char_positions.has(cell):
				order_handled.emit()
				return
		if order.skill.skill_map.bound_to_char:
			dmg_mng.skill_oneshot(order)
		else:
			dmg_mng.skill_mass(order)
		await dmg_mng.order_ended
	free_char_from_order(order)
	order_handled.emit()

func handle_heal(order : Order_heal):
	await get_tree().process_frame
	if has_node(order.attacker):
		dmg_mng.heal(order)
		await dmg_mng.order_ended
	free_char_from_order(order)
	order_handled.emit()

func free_char_from_order(order : Order_data):
	if has_node(order.attacker):
		var attacker : Character_node = get_node(order.attacker)
		attacker.has_order = false










#
