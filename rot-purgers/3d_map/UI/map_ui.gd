extends CanvasLayer

class_name Map_UI

@onready var map_generator : Map_generator = get_parent()
@onready var mini_char_stats: Mini_char_stats = %Mini_char_stats

signal map_spawn_character

var selected_char : Character_node

@onready var menues : Array[Control] = [
	%Turn_menu, %Char_action_menu, %Character_select_menu, %Focused_char_stats, %Spell_select_menu
]

func open_spawn_menu():
	map_generator.freze_selector = true
	%Character_select_menu.show()
	await get_tree().process_frame
	%Character_list.get_child(0).grab_focus()
	%Height_box.hide()

var button_to_char : Dictionary[BaseButton, Character_stats] = {}
var spawn_list : Dictionary[Character_stats, BaseButton]

func populate_spawn_list():
	for ch : Character_stats in GlobalData.ally_team:
		var bt : Button = load("uid://dk2af1blnp7lq").instantiate().duplicate()
		%Character_list.add_child(bt)
		button_to_char[bt] = ch
		spawn_list[ch] = bt
		bt.text = ch.name
		bt.pressed.connect(spawn_character.bind(ch))
		var ch_st : Character_stats = ch.duplicate()
		ch_st.stats_adjust()
		bt.focus_entered.connect(show_focus_char_stats.bind(ch_st))
		bt.mouse_entered.connect(func() -> void:
			bt.grab_focus()
		)
	%Character_list.move_child(%Close_spawn, %Character_list.get_children().size() - 1)

func show_focus_char_stats(ch : Character_stats):
	%Focused_char_stats.update_stats(ch)
	%Focused_char_stats.show()
	%Height_box.hide()

func close_spawn_menu():
	map_generator.freze_selector = false
	$Focused_char_stats.hide()
	%Character_select_menu.hide()
	%Height_box.show()

func spawn_character(ch : Character_stats):
	map_spawn_character.emit(ch)
	button_to_char.erase(spawn_list[ch])
	spawn_list[ch].queue_free()
	spawn_list.erase(ch)
	GlobalData.ally_team.erase(ch)
	close_spawn_menu()

func show_mini_stats(ch : Character_stats):
	%Mini_char_stats.update_stats(ch)
	%Mini_char_stats.show()

func hide_mini_stats():
	%Mini_char_stats.hide()

func open_char_action_menu(ch : Character_node, id : int = 0):
	map_generator.freze_selector = true
	selected_char = ch
	hide_mini_stats()
	%Height_box.hide()
	%Char_action_menu.update_disabled(ch)
	%Char_action_menu.show()
	await get_tree().process_frame
	%Char_action_menu.focus(id)
	show_focus_char_stats(ch.stats)

func _on_char_action_menu_exit() -> void:
	show_mini_stats(selected_char.stats)
	%Char_action_menu.hide()
	%Height_box.show()
	$Focused_char_stats.hide()
	map_generator.freze_selector = false
	map_generator.state_select()
	%Spell_select_menu.clear_skills()
	%Spell_select_menu.hide()

func _on_char_action_menu_move() -> void:
	map_generator.spawn_select_zone(selected_char, Map_generator.states.MOVE)
	map_generator.freze_selector = false
	map_generator.state = Map_generator.states.MOVE
	%Char_action_menu.hide()
	%Height_box.show()
	$Focused_char_stats.hide()
	%Spell_select_menu.clear_skills()
	%Spell_select_menu.hide()

func _on_char_action_menu_attack() -> void:
	map_generator.spawn_select_zone(selected_char, Map_generator.states.ATTACK)
	map_generator.freze_selector = false
	map_generator.state = Map_generator.states.ATTACK
	%Char_action_menu.hide()
	%Height_box.show()
	$Focused_char_stats.hide()

func open_turn_menu():
	map_generator.freze_selector = true
	%Turn_menu.show()
	%Height_box.hide()
	await get_tree().process_frame
	%Turn_menu.focus()

func _on_turn_menu_exit() -> void:
	if map_generator is not Tutorial:
		await make_save()
	var main : Main_node = map_generator.get_parent()
	main.current_map_id = -1
	await main.load_background()
	main.show_menu()
	GlobalData.reset_data()
	map_generator.queue_free()

func close_all():
	if %Spell_select_menu.visible:
		%Spell_select_menu.hide()
		%Spell_select_menu.clear_skills()
		%Char_action_menu.focus(2)
		return
	for menu in menues:
		menu.hide()
	map_generator.freze_selector = false
	map_generator.state_select()
	%Height_box.show()
	if map_generator.char_positions.has(map_generator.selected_cell):
		show_mini_stats(map_generator.char_positions[map_generator.selected_cell].stats)
	map_generator.try_mouse_raycast()

func _on_turn_menu_execute() -> void:
	%Turn_menu.hide()
	BattleHandler.execute_orders()
	await BattleHandler.orders_executed
	map_generator.freze_selector = false
	map_generator.state_select()

func _on_turn_menu_end_turn() -> void:
	BattleHandler.end_player_turn()
	%Turn_menu.hide()
	map_generator.state_select()

func _on_char_action_menu_defend() -> void:
	selected_char.defend()
	
	show_mini_stats(selected_char.stats)
	%Char_action_menu.hide()
	%Height_box.show()
	$Focused_char_stats.hide()
	map_generator.freze_selector = false
	map_generator.state_select()

func _on_char_action_menu_spell() -> void:
	%Spell_select_menu.load_skills(selected_char)
	%Spell_select_menu.show()
	await get_tree().process_frame
	%Spell_select_menu.focus()

func _on_spell_select_menu_skill_selected(skill : Skill_base) -> void:
	%Spell_select_menu.clear_skills()
	%Spell_select_menu.hide()
	%Char_action_menu.hide()
	%Height_box.show()
	%Focused_char_stats.hide()
	map_generator.freze_selector = false
	match skill.skill_type:
		Skill_base.skill_types.ATTACK:
			map_generator.display_skill(skill)
			map_generator.state = Map_generator.states.SKILL
		Skill_base.skill_types.HEAL:
			map_generator.state_select()
			BattleHandler.add_heal(selected_char, skill)
			selected_char.can_attack = false
			selected_char.has_order = true
		Skill_base.skill_types.TERRAIN:
			map_generator.terrain_skill_selected(skill)
			map_generator.state = Map_generator.states.SKILL_TERRAIN
			%Terrain_mod.show()

func _on_spell_select_menu_exit() -> void:
	%Spell_select_menu.clear_skills()
	%Spell_select_menu.hide()
	%Char_action_menu.focus()

func back_to_skill_selection():
	map_generator.freze_selector = true
	%Spell_select_menu.load_skills(selected_char)
	%Spell_select_menu.show()
	%Height_box.hide()
	%Char_action_menu.show()
	%Focused_char_stats.show()
	await get_tree().process_frame
	%Spell_select_menu.focus()

func flush_skill_menu():
	%Spell_select_menu.clear_skills()

func make_save():
	var game_save := Game_save.new()
	await game_save.make_save()
	@warning_ignore("redundant_await")
	await ResourceSaver.save(game_save, "user://save.tres")

func update_height(value : int):
	%Height_lb.text = str(value)

@onready var dead_zone : Rect2 = Rect2(%Terrain_mod.position, %Terrain_mod.size)
func update_terrain_cells(value : int):
	var cell_select : OptionButton = %Cell_select
	if value > cell_select.item_count:
		var check : bool = false
		if cell_select.item_count == 0:
			check = true
		cell_select.add_item("Cell " + str(value))
		if check:
			cell_select.select(0)
			await get_tree().process_frame
			_on_cell_select_item_selected(0)
	elif value < cell_select.item_count:
		cell_select.remove_item(cell_select.item_count - 1)

var selected_index : int
func _on_cell_select_item_selected(index: int) -> void:
	map_generator.move_camera_to_cell(index)
	selected_index = index
	var cell : Vector2i = map_generator.terrain_mod_selected_cells[index]
	%current_heilght_lb.text = "Current height : " + str(map_generator.terrain_map[cell].height)
	%mod_heilght_lb.text = "Modified height : " + str(map_generator.terrain_mod_data[cell].height)

@onready var terrain_mod_buttons : Dictionary[BaseButton, int] = {
	%terr_bt_01 : int(%terr_bt_01.text),
	%terr_bt_02 : int(%terr_bt_02.text),
	%terr_bt_03 : int(%terr_bt_03.text),
	%terr_bt_04 : int(%terr_bt_04.text),
	%terr_bt_05 : int(%terr_bt_05.text),
	%terr_bt_06 : int(%terr_bt_06.text),
}
func _on_terr_bt_pressed(source: BaseButton) -> void:
	var cell : Vector2i = map_generator.terrain_mod_selected_cells[selected_index]
	map_generator.terrain_mod_data[cell].height += terrain_mod_buttons[source]
	%mod_heilght_lb.text = "Modified height : " + str(map_generator.terrain_mod_data[cell].height)
	map_generator.move_map_cell_height(selected_index)

func _on_terrain_mod_button_pressed() -> void:
	map_generator.cast_terrain_mod()
	%Terrain_mod.hide()

func _ready() -> void:
	var pop : PopupMenu = %Cell_select.get_popup()
	pop.max_size = Vector2(9999, 500)

func _on_char_action_menu_rearange() -> void:
	%Rearange_menu.show()
	%Rearange_menu.load_char(selected_char)

func _on_rearange_menu_confirm() -> void:
	selected_char.car_rearange = false
	%Char_action_menu.update_disabled(selected_char)







#
