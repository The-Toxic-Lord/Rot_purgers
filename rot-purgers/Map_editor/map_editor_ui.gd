extends CanvasLayer

class_name Map_editor_UI

@onready var terrain_button_to_terrait_type : Dictionary[BaseButton, Terrain_data] = {}
@onready var map_editor : Map_editor = get_parent()

@onready var mouse_dead_zone : Array[Rect2] = [
	Rect2(%UI_panel_1.position, %UI_panel_1.size),
	Rect2(%UI_panel_2.position, %UI_panel_2.size)
	]

@onready var height_increment_buttons : Dictionary[BaseButton, int] = {
	%m10 : -10,
	%m5 : -5,
	%p5 : 5,
	%p10 : 10
}

signal generate_map

@onready var object_buttons : Dictionary[BaseButton, Map_object] = {
	%Spawn_zone : GlobalData.map_objects[0],
	%Enemy_zone : GlobalData.map_objects[1]
}

@onready var mode_buttons : Dictionary[int, Map_editor.modes] = {
	0 : Map_editor.modes.TERRAIN,
	1 : Map_editor.modes.OBJECTS,
	2 : Map_editor.modes.ENEMY
}

@onready var stats_le : Array[LineEdit] = [
	%Health_le, %Magic_le, %Strength_le, %Defence_le, %Magic_strenght_le, %Accuracy_le, %Speed_le, %Move_speed_le, %Jump_height_le, %Attack_distance_le, %Counter_le
]

var id_to_stat : Dictionary = {
	0 : "max_health",
	1 : "max_magic",
	2 : "strength",
	3 : "defence",
	4 : "magic_strenght",
	5 : "accuracy",
	6 : "speed",
	7 : "move_speed",
	8 : "jump_height",
	9 : "attack_distance",
	10 : "counter",
}

var enemy_data : Array[Character_stats]
var selected_enemy_data : Character_stats

func _ready() -> void:
	for terr_data in GlobalData.terrain_data_holder:
		terrain_button_to_terrait_type[make_terrain_button(terr_data)] = terr_data
	for i in GlobalData.enemy_data.size():
		var en_sel : OptionButton = %Enemy_selector
		var en_data : Character_stats = GlobalData.enemy_data[i]
		en_sel.add_icon_item(en_data.sprite , en_data.name, i)
	enemy_data = GlobalData.enemy_data
	for i in stats_le.size():
		stats_le[i].text = str(enemy_data[0].get(id_to_stat[i]))
	selected_enemy_data = enemy_data[0]

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
	bt.pressed.connect(terrain_button_pressed.bind(bt))
	return bt

@warning_ignore("unused_parameter")
func _on_map_size_text_submitted(new_text: String, source: LineEdit) -> void:
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

func terrain_button_pressed(source : BaseButton):
	_on_mode_button_pressed(0)
	untoggle_terrain_buttons(source)
	untoggle_object_buttons()
	if source.button_pressed:
		map_editor.selected_terrain_data = terrain_button_to_terrait_type[source]
	else:
		map_editor.selected_terrain_data = null

func untoggle_terrain_buttons(source = null):
	for bt in terrain_button_to_terrait_type:
		if bt != source:
			bt.button_pressed = false

func _on_height_text_changed(new_text: String) -> void:
	if new_text.is_empty():
		map_editor.selected_height = 0
		return
	if new_text.is_valid_int():
		map_editor.selected_height = new_text.to_int()
		return
	%Height.text = str(map_editor.selected_height)

func _on_height_increment_pressed(source: BaseButton) -> void:
	%Height.text = str(%Height.text.to_int() + height_increment_buttons[source])
	_on_height_text_changed(%Height.text)

func _on_generate_pressed() -> void:
	generate_map.emit()

func _on_depth_text_submitted(new_text: String) -> void:
	if new_text.is_empty():
		map_editor.selected_depth = 0
		%Depth.text = "0"
		return
	if new_text.is_valid_int():
		map_editor.selected_depth = new_text.to_int()
		return
	%Depth.text = str(map_editor.selected_depth)

func _on_object_button_pressed(source: BaseButton) -> void:
	_on_mode_button_pressed(1)
	untoggle_object_buttons(source)
	untoggle_terrain_buttons()
	if source.button_pressed:
		map_editor.selected_object = object_buttons[source]
	else:
		map_editor.selected_object = null

func untoggle_object_buttons(source = null):
	for bt in object_buttons:
		if bt == source:
			continue
		bt.button_pressed = false

func _on_mode_button_pressed(index : int) -> void:
	%Mode.selected = index
	map_editor.paint_mode = mode_buttons[index]

func _on_save_pressed() -> void:
	map_editor.save_map_data()

func _on_load_pressed() -> void:
	map_editor.load_map_data()

func load_data(map_size : Vector2i):
	%map_x.text = str(map_size.x)
	%map_y.text = str(map_size.y)

func _on_enemy_selector_item_selected(index: int) -> void:
	selected_enemy_data = enemy_data[index]
	for i in stats_le.size():
		stats_le[i].text = str(enemy_data[index].get(id_to_stat[i]))

func _on_stat_text_changed(new_text: String, source: LineEdit) -> void:
	var id : int = stats_le.find(source)
	if new_text.is_empty():
		source.text = str(selected_enemy_data.get(id_to_stat[id]))
		return
	if new_text.is_valid_int():
		selected_enemy_data.set(id_to_stat[id], new_text.to_int())
		return
	source.text = str(selected_enemy_data.get(id_to_stat[id]))

var id_to_AI_type : Dictionary[int, Character_stats.AI_types] = {
	0 : Character_stats.AI_types.NORMAL,
	1 : Character_stats.AI_types.TURRET,
	2 : Character_stats.AI_types.CHARGER
}

func _on_ai_type_item_selected(index: int) -> void:
	selected_enemy_data.AI_type = id_to_AI_type[index]







#
