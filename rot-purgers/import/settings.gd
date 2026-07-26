extends Control

@onready var main_menu : Main_menu_UI = get_parent()

@onready var music_bus := AudioServer.get_bus_index("Music")
func _on_music_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(music_bus, value*0.01)
	_settings.music = value

@onready var sfx_bus := AudioServer.get_bus_index("Sfx")
func _on_sfx_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(sfx_bus, value*0.01)
	_settings.sfx = value

@onready var master_bus := AudioServer.get_bus_index("Master")
func _on_master_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(master_bus, value*0.01)
	_settings.master = value

func _on_back_pressed() -> void:
	save_data()
	main_menu.settings_exit()

var _settings := {resolution = 0, fullscreen = false, master = 100.0, sfx = 100.0, music = 100.0}

func _on_full_screen_check_toggled(toggled_on: bool) -> void:
	_settings.fullscreen = toggled_on
	update()

var res_dict : Dictionary[int, Vector2] = {
	0: Vector2(640,480),
	1: Vector2(1280,720),
	2: Vector2(1920,1080)
}
func _on_option_button_item_selected(index: int) -> void:
	_settings.resolution = index
	update()

func update():
	if _settings.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	#DisplayServer.window_set_size(res_dict[_settings.resolution])
	get_window().set_size(res_dict[_settings.resolution])

func save_data():
	var settings_save := Settings_save.new()
	settings_save._settings = _settings
	ResourceSaver.save(settings_save, "user://settings.tres")
	#menu.save._settings = _settings
	#menu.save_data()

func load_settings():
	if ResourceLoader.exists("user://settings.tres"):
		var settings_save : Settings_save = ResourceLoader.load("user://settings.tres")
		_settings = settings_save._settings
		%OptionButton.selected = _settings.resolution
		%Full_screen_check.button_pressed = _settings.fullscreen
		%Master.value = _settings.master
		%Music.value = _settings.music
		%Sfx.value = _settings.sfx

func grab():
	%OptionButton.grab_focus()

func _ready() -> void:
	load_settings()


#
