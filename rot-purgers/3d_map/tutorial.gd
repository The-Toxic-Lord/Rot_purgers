extends Map_generator

class_name Tutorial

func tutorial_sequence():
	GlobalData.ally_team[0].skills.append(load("uid://dhhs70r647yrx"))
	GlobalData.ally_team[0].skills.append(load("uid://d0lnxgg3anglw"))
	await get_tree().process_frame
	DialogueBalloon.start(map_data.text_data, "t2")
	while true:
		if %Camera_position.movement_bools[0]:
			break
		await get_tree().create_timer(0.1).timeout
	DialogueBalloon.start(map_data.text_data, "t3")
	while true:
		if %Camera_position.movement_bools[1]:
			break
		await get_tree().create_timer(0.1).timeout
	DialogueBalloon.start(map_data.text_data, "t4")
	while true:
		if %Camera_position.movement_bools[2]:
			break
		await get_tree().create_timer(0.1).timeout
	DialogueBalloon.start(map_data.text_data, "t5")
	while true:
		if ally_spawn_check:
			break
		await get_tree().create_timer(0.1).timeout
	DialogueBalloon.start(map_data.text_data, "t6")
	while true:
		if spawn_move_check:
			break
		await get_tree().create_timer(0.1).timeout
	DialogueBalloon.start(map_data.text_data, "t7")
	while true:
		if move_check:
			break
		await get_tree().create_timer(0.1).timeout
	DialogueBalloon.start(map_data.text_data, "t8")
	while true:
		if spawn_attack_check:
			break
		await get_tree().create_timer(0.1).timeout
	DialogueBalloon.start(map_data.text_data, "t9")
	while true:
		if bound_skill_check:
			break
		await get_tree().create_timer(0.1).timeout
	DialogueBalloon.start(map_data.text_data, "t10")
	while true:
		if unbound_skill_check:
			break
		await get_tree().create_timer(0.1).timeout
	DialogueBalloon.start(map_data.text_data, "t11")
	while true:
		if skill_order_check:
			break
		await get_tree().create_timer(0.1).timeout
	DialogueBalloon.start(map_data.text_data, "t12")
	while true:
		if %Map_UI.execution_check:
			break
		await get_tree().create_timer(0.1).timeout
	DialogueBalloon.start(map_data.text_data, "t13")
	while true:
		if end_turn_check:
			break
		await get_tree().create_timer(0.1).timeout
	DialogueBalloon.start(map_data.text_data, "t14")
	while true:
		if skill_move_check:
			break
		await get_tree().create_timer(0.1).timeout
	DialogueBalloon.start(map_data.text_data, "t15")
	while true:
		if undo_check:
			break
		await get_tree().create_timer(0.1).timeout
	DialogueBalloon.start(map_data.text_data, "t16")
	await DialogueManager.dialogue_ended
	%Map_UI._on_turn_menu_exit()

var ally_spawn_check := false
func spawn_ally(ch : Character_stats):
	super(ch)
	ally_spawn_check = true

var spawn_move_check := false
var spawn_attack_check := false
# CHANGE
func spawn_select_zone(ch_node : Character_node, st : states):
	match st:
		states.MOVE:
			spawn_move_check = true
		states.ATTACK:
			spawn_attack_check = true
	super(ch_node, st)

var move_check := false
func move_character():
	super()
	move_check = true

var bound_skill_check := false
func make_bound_skill(skill : Skill_base):
	super(skill)
	bound_skill_check = true

var unbound_skill_check := false
func make_unboun_skill(skill : Skill_base):
	super(skill)
	unbound_skill_check = true

var end_turn_check := false

var undo_check := false
func _input(event: InputEvent) -> void:
	super(event)
	if event.is_action_pressed("undo"):
		undo_check = true

var skill_move_check := false
func finalize_skill_move():
	super()
	skill_move_check = true

var skill_order_check := false
func add_skill_order():
	super()
	skill_order_check = true


func tutorial_sequence_environment():
	await get_tree().process_frame
	while true:
		if BattleHandler.allies.size() == 0:
			await get_tree().create_timer(0.1).timeout
			continue
		if BattleHandler.allies[0].gained_rot:
			break
		await get_tree().create_timer(0.1).timeout
	DialogueBalloon.start(map_data.text_data, "t_e_03")
	while true:
		if BattleHandler.allies[0].rot_reverse:
			break
		await get_tree().create_timer(0.1).timeout
	DialogueBalloon.start(map_data.text_data, "t_e_04")
	while true:
		if %Map_UI.terrain_spell_mod_used:
			break
		await get_tree().create_timer(0.1).timeout
	DialogueBalloon.start(map_data.text_data, "t_e_05")
	while true:
		if terrain_mod_cast:
			break
		await get_tree().create_timer(0.1).timeout
	DialogueBalloon.start(map_data.text_data, "t_e_06")

var terrain_mod_cast := false
func cast_terrain_mod():
	super()
	terrain_mod_cast = true


func tutorial_sequence_char():
	GlobalData.ally_team[0].skills.append(load("uid://dkwukbqlnba8d"))
	while true:
		if %Map_UI.protection_skill_selected:
			break
		await get_tree().create_timer(0.1).timeout
	DialogueBalloon.start(map_data.text_data, "t_c_02")
	while true:
		if end_turn_check and BattleHandler.state == Battle_handler.states.PLAYER:
			break
		await get_tree().create_timer(0.1).timeout
	DialogueBalloon.start(map_data.text_data, "t_c_03")
	end_turn_check = false
	BattleHandler.allies[0].stats.skills.remove_at(0)
	BattleHandler.allies[0].stats.skills.append(load("uid://dfefbrwmuckxc"))
	while true:
		if %Map_UI.heal_used:
			break
		await get_tree().create_timer(0.1).timeout
	DialogueBalloon.start(map_data.text_data, "t_c_04")
	%Map_UI.execution_check = false
	while true:
		if %Map_UI.execution_check:
			break
		await get_tree().create_timer(0.1).timeout
	DialogueBalloon.start(map_data.text_data, "t_c_05")
	end_turn_check = false
	while true:
		if end_turn_check:
			break
		await get_tree().create_timer(0.1).timeout
	DialogueBalloon.start(map_data.text_data, "t_c_06")
	end_turn_check = false
	while true:
		if %Map_UI.rearrange_used:
			break
		await get_tree().create_timer(0.1).timeout
	DialogueBalloon.start(map_data.text_data, "t_c_07")
	%Map_UI.rearrange_used = false
	while true:
		if %Map_UI.rearrange_used:
			break
		await get_tree().create_timer(0.1).timeout
	DialogueBalloon.start(map_data.text_data, "t_c_08")
	%Map_UI.rearrange_used = false
	while true:
		if %Map_UI.rearrange_used:
			break
		await get_tree().create_timer(0.1).timeout
	DialogueBalloon.start(map_data.text_data, "t_c_09")
	await DialogueManager.dialogue_ended
	%Map_UI._on_turn_menu_exit()






#
