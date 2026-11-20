extends CanvasLayer

class_name Main_menu_UI

@onready var main : Main_node = get_parent()
@onready var save_menu: Save_menu = %Save_menu

var in_main_menu := true
var last_bt_pressed : BaseButton

func _ready() -> void:
	if !ResourceLoader.exists("user://save.tres"):
		%Load.disabled = true
	%New_game.grab_focus()
	await load_user_save()

func _on_map_editor_pressed() -> void:
	%Menu.hide()
	main._on_map_editor_pressed()

func _on_load_pressed() -> void:
	await close_all()
	save_menu.show()
	save_menu.hide_new_save()
	save_menu.focus(false)
	last_bt_pressed = %Load

func _on_new_game_pressed() -> void:
	await close_all()
	%Difficuly_menu.show()
	%normal_bt.grab_focus()
	last_bt_pressed = %New_game

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_settings_pressed() -> void:
	%Menu.hide()
	%Settings.show()
	%Settings.grab()
	last_bt_pressed = %Settings_button

func settings_exit():
	%Menu.show()
	%Settings.hide()
	%Settings_button.grab_focus()

func show_menu():
	%Menu.show()
	%New_game.grab_focus()
	if ResourceLoader.exists("user://save.tres"):
		%Load.disabled = false

func hide_menu():
	%Menu.hide()
	%Tutorial_menu.hide()

@onready var animation_player: AnimationPlayer = %AnimationPlayer
func game_end(line : String):
	match line:
		"end_b":
			%Victory_lb.text = "The End" + "\n" + "Ending B"
		"end_a":
			%Victory_lb.text = "Victory!" + "\n" + "Ending A"
		"game_over":
			%Victory_lb.text = "Game Over"
	%Victory.show()
	await get_tree().create_timer(0.5).timeout
	animation_player.play("show_victory_lb")
	await animation_player.animation_finished
	%Victory.hide()
	main.load_background()
	show_menu()
	if line != "game_over":
		user_save.add_achievement(GlobalData.difficulty, line)

var user_save : User_save
func load_user_save():
	if ResourceLoader.exists("user://saves/user.res"):
		user_save = load("user://saves/user.res")
	else:
		user_save = User_save.new()

@onready var tutorial_btsns : Dictionary[BaseButton, String] = {
	%Tutorial_01 : "uid://b7t1sx6ug0nmh",
	%Tutorial_02 : "uid://cfeal5nlxu50a",
	%Tutorial_03 : "res://map_data_res/tutorial_03.tres"
}

func show_tutorial():
	%Tutorial_menu.show()

func _on_tutorial_bt_pressed(sourse : BaseButton) -> void:
	%Menu.hide()
	%Tutorial_menu.hide()
	main.load_scene_path(tutorial_btsns[sourse], "tutorial")

func _on_exit_demo_pressed() -> void:
	main.close_map()
	main.load_background()
	show_menu()
	%Demo_victory.hide()

func _on_credits_pressed() -> void:
	%Credit_box.show()
	%Menu.hide()
	last_bt_pressed = %Credits

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
	DialogueBalloon.is_working = false
	%Save_menu.hide()
	ObjectLink.main.load_save(save_name)

var achievement_line : Array[String] = []
func animate_achievement(text : String):
	if animation_player.is_playing():
		achievement_line.append(text)
		return
	%Achievement_lb.text = text
	animation_player.play("show_achievement")
	await animation_player.animation_finished
	if achievement_line.has(text):
		achievement_line.remove_at(0)
	if !achievement_line.is_empty():
		animate_achievement(achievement_line[0])

@export var achievement_texts : Dictionary[String, String] = {}

func _on_tutorial_pressed() -> void:
	await close_all()
	%Tutorial_menu.show()
	%Tutorial_01.grab_focus()

func _input(event: InputEvent) -> void:
	if !in_main_menu:
		return
	if event.is_action_pressed("menu_back"):
		if %Difficuly_menu.visible:
			%Difficuly_menu.hide()
			%New_game.grab_focus()
		elif %Tutorial_menu.visible:
			%Tutorial_menu.hide()
			%Tutorial.grab_focus()


@onready var small_menus : Array[Node] = [
	%Tutorial_menu, %Difficuly_menu, %Save_menu
]
func close_all():
	for menu in small_menus:
		menu.hide()

func focus(node : Control = %New_game):
	node.grab_focus()




#
