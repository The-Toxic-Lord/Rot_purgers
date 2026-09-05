extends Node

class_name Battle_handler

enum states { PLAYER, ENEMY, ANIMATION }
var state : states = states.PLAYER
var prev_state : states

var map_gen : Map_generator

var allies : Array[Character_node] = []
var enemies : Array[Character_node] = []

var protected_cells : Dictionary[Character_node, Array] = {}

@onready var dmg_mng : Damage_manager = $Damage_manager
var order_array : Array[Order_data] = []

@onready var en_mng : Enemy_manager = $Enemy_manager

var main_node : Main_node

signal order_handled
signal orders_executed

func new_battle_start():
	dmg_mng.map_gen = map_gen
	state = states.PLAYER
	allies = []
	enemies = []
	order_array = []
	en_mng.map_gen = map_gen

func add_attack(attacker : Character_node, target : Character_node):
	var order_data := Order_data.new()
	order_data.make(attacker, target)
	order_array.append(order_data)

func add_skill(attacker : Character_node, skill : Skill_base, 
damage_cells : Array[Vector2i], move_cells : Array[Vector2i], selected_cell : Vector2i):
	var order := Order_skill_data.new()
	order.make_skill(attacker, skill, damage_cells, move_cells, selected_cell)
	order_array.append(order)

func add_heal(attacker : Character_node, skill : Skill_base):
	var order := Order_heal.new()
	order.make_heal(attacker, skill)
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
		var attacker : Character_node = get_node(order_data.attacker)
		map_gen.set_camera_target(attacker)
		map_gen.set_selector(attacker.map_pos)
		attacker.can_undo_move = false
		if order_data is Order_skill_data:
			handle_skill(order_data)
		elif order_data is Order_heal:
			handle_heal(order_data)
		elif order_data is Order_protect:
			handle_protect(order_data)
		elif order_data is Order_spawn:
			handle_spawn(order_data)
		else:
			handle_attack(order_data)
		await order_handled
	order_array.clear()
	state = prev_state
	if map_gen != null:
		map_gen.camera.follow_target = null
		orders_executed.emit()

func end_player_turn():
	if map_gen == null:
		return
	state = states.ENEMY
	if !order_array.is_empty():
		execute_orders()
		await orders_executed
	if map_gen == null:
		return
	en_mng.start_enemy_turn()
	await en_mng.enemies_turn_ended
	start_player_turn()

func start_player_turn():
	for char_node in allies:
		if protected_cells.has(char_node):
			protected_cells.erase(char_node)
		char_node.deflects_left = 0
	if map_gen == null:
		return
	map_gen.set_camera_target()
	for ch in allies:
		ch.new_round()
	for ch in enemies:
		ch.new_round()
	state = states.PLAYER
	map_gen.freze_selector = false
	map_gen.set_selector(map_gen.selected_cell)
	
	if map_gen is Tutorial:
		map_gen.end_turn_check = true

func char_dies(char_node : Character_node):
	if enemies.has(char_node):
		enemies.erase(char_node)
		await map_gen.remove_enemy(char_node)
		if enemies.is_empty() and map_gen.map_data.end_condition == Map_data.map_end_conditions.ENEMY:
			end_battle()
	else:
		allies.erase(char_node)
		map_gen.remove_enemy(char_node)
		if allies.is_empty() and GlobalData.ally_team.is_empty():
			game_over()
			# ADD game_over

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
		if order.skill.is_one_shot:
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

func remove_order(char_node : Character_node):
	var attacker_path : NodePath = char_node.get_path()
	
	for order in order_array:
		if order.attacker == attacker_path:
			order_array.erase(order)
			return

func end_battle():
	var ally_data_array : Array[Character_stats] = []
	for ally in allies:
		ally.stats.new()
		ally_data_array.append(ally.stats)
	GlobalData.ally_team.append_array(ally_data_array)
	map_gen.get_parent().load_map()

func game_over():
	main_node.game_over()

func add_protect(attacker : Character_node, skill : Skill_base):
	var order := Order_protect.new()
	order.make_order(attacker, skill)
	order_array.append(order)

func handle_protect(order : Order_protect):
	await get_tree().process_frame
	if has_node(order.attacker):
		var attacker : Character_node = get_node(order.attacker)
		attacker.can_move = false
		attacker.has_order = false
		attacker.deflects_left = order.skill.deflect_times
		var pr_cells : Array[Vector2i] = map_gen.get_flow_cells(attacker.map_pos,
		order.skill.max_dist, false, false, order.skill.max_height_difference, true, false)
		protected_cells[attacker] = pr_cells
	order_handled.emit()

func add_spawn(stats : Character_stats, cell : Vector2i, 
dir : Map_generator.directions, attacker : Character_node):
	var spawn_order := Order_spawn.new()
	spawn_order.make_spawn_data(stats, cell, dir, attacker)
	order_array.append(spawn_order)

func handle_spawn(order : Order_spawn):
	await get_tree().process_frame
	await map_gen.spawn_enemy(order.stats, order.target_cell, order.dir)
	order_handled.emit()

func _ready() -> void:
	%Enemy_manager.get_new_dir(Vector2i(10,10), Vector2i(12, 12))





#
