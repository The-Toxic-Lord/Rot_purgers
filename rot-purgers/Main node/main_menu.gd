extends CanvasLayer

class_name Main_menu_UI

@onready var main : Main_node = get_parent()
@onready var save_menu: Save_menu = %Save_menu

func _ready() -> void:
	if !ResourceLoader.exists("user://save.tres"):
		%Load.disabled = true
	%New_game.grab_focus()

func _on_map_editor_pressed() -> void:
	%Menu.hide()
	main._on_map_editor_pressed()

func _on_load_pressed() -> void:
	save_menu.show()
	save_menu.hide_new_save()
	#main._on_load_pressed()

func _on_new_game_pressed() -> void:
	%Menu.hide()
	main.load_scene_path(GlobalData.map_data_path[0])

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_settings_pressed() -> void:
	%Menu.hide()
	%Settings.show()
	%Settings.grab()

func settings_exit():
	%Menu.show()
	%Settings.hide()

func show_menu():
	%Menu.show()
	if ResourceLoader.exists("user://save.tres"):
		%Load.disabled = false

func hide_menu():
	%Menu.hide()

func on_game_over():
	GlobalData.clear_data()
	%Game_over_screen.show()
	await get_tree().create_timer(3).timeout
	main.close_map()
	main.load_background()
	show_menu()
	%Game_over_screen.hide()

func on_victory():
	GlobalData.clear_data()
	%Demo_victory.show()

func _on_tutorial_pressed() -> void:
	%Menu.hide()
	main.load_tutorial()

func _on_exit_demo_pressed() -> void:
	main.close_map()
	main.load_background()
	show_menu()
	%Demo_victory.hide()

func _on_credits_pressed() -> void:
	%Credit_box.show()
	%Menu.hide()

func _on_credit_back_pressed() -> void:
	%Credit_box.hide()
	%Menu.show()




#func _notification(what: int) -> void:
	##ADD to me
	##get_tree().set_auto_accept_quit(false)
	#if what == NOTIFICATION_WM_CLOSE_REQUEST:
		#print("lol")
	#if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		#print(1)

#func _on_save_menu_load_save(save_name: String) -> void:
	#%Save_menu.hide()
	#ObjectLink.main.load_save(save_name)

func _on_save_menu_load_save(save_name: String) -> void:
	%Save_menu.hide()
	ObjectLink.main.load_save(save_name)








#
