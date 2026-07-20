extends CanvasLayer

class_name Map_editor_UI

@onready var terrain_button_to_terrait_type : Dictionary[BaseButton, Terrain_data] = {}
@onready var map_editor : Map_editor = get_parent()

@onready var mouse_dead_zone : Array[Rect2] = [
	Rect2(%UI_panel_1.position, %UI_panel_1.size),
	Rect2(%UI_panel_2.position, %UI_panel_2.size)
	]

func _ready() -> void:
	for terr_data in GlobalData.terrain_data_holder:
		terrain_button_to_terrait_type[make_terrain_button(terr_data)] = terr_data

func make_terrain_button(terr_data : Terrain_data) -> BaseButton:
	var bt := Button.new()
	bt.custom_minimum_size = Vector2i(64, 64)
	var style_box : StyleBoxTexture = load("uid://8pv7eye5uwl5").duplicate(true)
	style_box.texture = terr_data.sprite
	bt.add_theme_stylebox_override("normal", style_box)
	bt.add_theme_stylebox_override("hover", style_box)
	style_box = load("uid://5wxiklgne4b7").duplicate(true)
	style_box.texture = terr_data.sprite
	bt.add_theme_stylebox_override("pressed", style_box)
	bt.toggle_mode = true
	%Terrain_grid.add_child(bt)
	bt.pressed.connect(terrain_button_toggled.bind(bt))
	return bt

func _on_map_size_text_changed(new_text: String, source: LineEdit) -> void:
	if new_text.is_empty():
		if source == %map_x:
			map_editor.map_size.x = 0
		else:
			map_editor.map_size.y = 0
		return
	if new_text.is_valid_int():
		if source == %map_x:
			map_editor.map_size.x = new_text.to_int()
		else:
			map_editor.map_size.y = new_text.to_int()
		return
	if source == %map_x:
		%map_x.text = str(map_editor.map_size.x)
	else:
		%map_y.text = str(map_editor.map_size.y)

@warning_ignore("unused_parameter")
func _on_map_size_text_submitted(new_text: String, source: LineEdit) -> void:
	source.release_focus()

func terrain_button_toggled(sourse : BaseButton):
	for bt in terrain_button_to_terrait_type:
		if bt != sourse:
			bt.button_pressed = false
	if sourse.button_pressed:
		map_editor.selected_terrain_data = terrain_button_to_terrait_type[sourse]
	else:
		map_editor.selected_terrain_data = null

func _on_height_text_changed(new_text: String) -> void:
	if new_text.is_empty():
		map_editor.selected_height = 0
		return
	if new_text.is_valid_int():
		map_editor.selected_height = new_text.to_int()
		return
	%Height.text = map_editor.selected_height




#
