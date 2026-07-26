extends Map_UI

var execution_check := false

func _on_turn_menu_execute() -> void:
	%Turn_menu.hide()
	BattleHandler.execute_orders()
	await BattleHandler.orders_executed
	map_generator.freze_selector = false
	map_generator.state_select()
	execution_check = true

func spawn_character(ch : Character_stats):
	map_generator.freze_selector = false
	map_generator.state = Map_generator.states.SELECT
	map_spawn_character.emit(ch)
	button_to_char.erase(spawn_list[ch])
	spawn_list[ch].queue_free()
	spawn_list.erase(ch)
	GlobalData.ally_team.erase(ch)
	close_spawn_menu()
