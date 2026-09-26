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

@onready var mode_buttons : Dictionary[int, Map_editor.modes] = {
	0 : Map_editor.modes.TERRAIN,
	1 : Map_editor.modes.OBJECTS,
	2 : Map_editor.modes.ENEMY
}

@onready var stats_le : Array[LineEdit] = [
	%Health_le, %Magic_le, %Strength_le, %Defence_le, %Magic_strenght_le,\
	 %Accuracy_le, %Speed_le, %Move_speed_le, %Jump_height_le, %Attack_distance_le, 
	%Counter_le, %trigger_dist, %number_of_pc, %Start_height
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
	11 : "trigger_distance",
	12 : "number_of_pc",
	13 : "start_height"
}

var enemy_data : Array[Character_stats]
var selected_enemy_data : Character_stats

func _ready() -> void:
	load_object_data()
	load_terrain()
	await get_tree().process_frame
	var pop : PopupMenu = %Terrain_selector.get_popup()
	pop.add_theme_constant_override("icon_max_width", 32)
	for i in GlobalData.enemy_data.size():
		var en_sel : OptionButton = %Enemy_selector
		var en_data : Character_stats = GlobalData.enemy_data[i]
		en_sel.add_icon_item(en_data.sprite , en_data.name, i)
	enemy_data = GlobalData.enemy_data
	for i in stats_le.size():
		stats_le[i].text = str(enemy_data[0].get(id_to_stat[i]))
	selected_enemy_data = enemy_data[0]
	%Enemy_selector.get_popup().add_theme_constant_override("icon_max_width", 64)
	for type in Map_object.types.keys():
		%Object_type.add_item(type)

#region TERRAIN

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

func _on_depth_text_submitted(new_text: String) -> void:
	if new_text.is_empty():
		map_editor.selected_depth = 0
		%Depth.text = "0"
		return
	if new_text.is_valid_int():
		map_editor.selected_depth = new_text.to_int()
		return
	%Depth.text = str(map_editor.selected_depth)

func _on_shader_dir_item_selected(index: int) -> void:
	match index:
		0:
			map_editor.selected_dir = Map_generator.directions.N
		1:
			map_editor.selected_dir = Map_generator.directions.E
		2:
			map_editor.selected_dir = Map_generator.directions.S
		3:
			map_editor.selected_dir = Map_generator.directions.W

#endregion

func _on_generate_pressed() -> void:
	generate_map.emit()

enum file_states { SAVE, LOAD, OBJECT_DATA, NEXT }
var save_location : String
var file_state : file_states 
func _on_save_pressed() -> void:
	file_state = file_states.SAVE
	%Save.release_focus()
	%FileDialog.file_mode = FileDialog.FileMode.FILE_MODE_SAVE_FILE
	%FileDialog.popup()

func _on_load_pressed() -> void:
	file_state = file_states.LOAD
	%Load.release_focus()
	%FileDialog.file_mode = FileDialog.FileMode.FILE_MODE_OPEN_FILE
	%FileDialog.popup()

func load_data(map_data : Map_data):
	%map_x.text = str(map_data.map_size.x)
	%map_y.text = str(map_data.map_size.y)
	%Magic_cost.text = str(map_data.magic_cost_adjustment)
	magic_cost = map_data.magic_cost_adjustment
	next_map_selected(map_data.next_map_path)
	%Mode.selected = 0
	_on_mode_item_selected(0)

func _on_enemy_selector_item_selected(index: int) -> void:
	load_enemy_data(enemy_data[index].duplicate(true), false)
	map_editor.paint_mode = mode_buttons[2]
	%Mode.selected = 2

func _on_stat_text_changed(new_text: String, source: LineEdit) -> void:
	var id : int = stats_le.find(source)
	if new_text.is_empty():
		source.text = str(selected_enemy_data.get(id_to_stat[id]))
		return
	if new_text.is_valid_int():
		selected_enemy_data.set(id_to_stat[id], new_text.to_int())
		return
	source.text = str(selected_enemy_data.get(id_to_stat[id]))

func _on_ai_type_item_selected(index: int) -> void:
	@warning_ignore("int_as_enum_without_cast")
	selected_enemy_data.AI_type = index

var dir_arr : Array[Map_generator.directions] = [Map_generator.directions.N, Map_generator.directions.E, 
Map_generator.directions.S, Map_generator.directions.W]
func _on_start_dir_item_selected(index: int) -> void:
	selected_enemy_data.start_dir = dir_arr[index]

func load_enemy_data(enemy : Character_stats, reset_selector := true):
	selected_enemy_data = enemy
	for i in stats_le.size():
		stats_le[i].text = str(enemy.get(id_to_stat[i]))
	%AI_type.selected = enemy.AI_type
	%start_dir.selected = dir_arr.find(enemy.start_dir)
	if reset_selector:
		%Enemy_selector.selected = -1
	await load_skills()
	%Enemy_maker.show()
	%rot_stage.selected = enemy.rot_stage
	if mouse_dead_zone.size() == 2:
		mouse_dead_zone.append(Rect2(%Enemy_maker.position, %Enemy_maker.size))

func _on_open_maker_pressed() -> void:
	%Enemy_maker.show()
	if mouse_dead_zone.size() == 2:
		mouse_dead_zone.append(Rect2(%Enemy_maker.position, %Enemy_maker.size))

func _on_confirm_stats_pressed() -> void:
	%Enemy_maker.hide()
	if mouse_dead_zone.size() > 2:
		mouse_dead_zone.remove_at(2)

func load_skills():
	var ch : Array[Node] = %Skill_box.get_children()
	for i in ch.size():
		ch[i].queue_free()
	for skill in selected_enemy_data.potential_skills:
		var slot : Map_editor_skill_slot = load("uid://dli2qqtdecn8p").instantiate()
		%Skill_box.add_child(slot)
		var enabled := false
		if selected_enemy_data.skills.has(skill):
			enabled = true
		slot.set_data(skill.name, enabled)
		slot.skill_enabled.connect(enable_skill.bind(skill))
		slot.skill_disabled.connect(enable_skill.bind(skill))

func enable_skill(skill : Skill_base):
	if !selected_enemy_data.skills.has(skill):
		selected_enemy_data.skills.append(skill)

func disable_skill(skill : Skill_base):
	if selected_enemy_data.skills.has(skill):
		selected_enemy_data.skills.erase(skill)

@export var map_objects_file_path : String
var map_objects : Array[Map_object] = []
func load_object_data():
	var dir_acc := DirAccess.open(map_objects_file_path)
	var files := dir_acc.get_files()
	for i in files.size():
		var obj_res : Map_object = ResourceLoader.load(map_objects_file_path + files[i])
		map_objects.append(obj_res)
		%Object_selector.add_icon_item(obj_res.sprite, obj_res.name)
	map_editor.selected_object = map_objects[0]

func _on_object_selector_item_selected(index: int) -> void:
	map_editor.selected_object = map_objects[index]
	map_editor.paint_mode = mode_buttons[1]
	%Mode.selected = 1

func _on_terrain_selector_item_selected(index: int) -> void:
	map_editor.paint_mode = mode_buttons[0]
	map_editor.selected_terrain_data = map_terrain[index]
	%Mode.selected = 0

@export var map_terrain_file_path : String
var map_terrain : Array[Terrain_data] = []
func load_terrain():
	var dir_acc := DirAccess.open(map_terrain_file_path)
	var files := dir_acc.get_files()
	for i in files.size():
		var obj_res : Terrain_data = ResourceLoader.load(map_terrain_file_path + files[i])
		map_terrain.append(obj_res)
		%Terrain_selector.add_icon_item(obj_res.sprite, files[i])
	map_editor.selected_terrain_data = map_terrain[0]

func _on_mode_item_selected(index: int) -> void:
	while mouse_dead_zone.size() > 2:
		mouse_dead_zone.remove_at(2)
	map_editor.paint_mode = mode_buttons[index]
	if index == 1:
		%Object_maker.show()
		var rect := Rect2(%Object_maker.position, %Object_maker.size)
		mouse_dead_zone.append(rect)
	else:
		%Object_maker.hide()

func _on_object_dir_select_item_selected(index: int) -> void:
	match index:
		0:
			map_editor.selected_object.direction = Map_generator.directions.N
		1:
			map_editor.selected_object.direction = Map_generator.directions.E
		2:
			map_editor.selected_object.direction = Map_generator.directions.S
		3:
			map_editor.selected_object.direction = Map_generator.directions.W

func load_seleced_object():
	%Object_dir_select.selected = map_editor.selected_object.direction
	%Object_type.selected = map_editor.selected_object.object_type
	_on_object_type_item_selected(%Object_type.selected)

func _on_file_dialog_file_selected(path: String) -> void:
	match file_state:
		file_states.SAVE:
			map_editor.save_map_data(path)
		file_states.LOAD:
			map_editor.load_map_data(path)
		file_states.OBJECT_DATA:
			object_data_selected(path)
		file_states.NEXT:
			next_map_selected(path)

@onready var exit_controlls : Array[Control] = [
	%Label15, %Data_name, %Select_data_bt
]

func _on_object_type_item_selected(index: int) -> void:
	@warning_ignore("int_as_enum_without_cast")
	map_editor.selected_object.object_type = index
	if index == Map_object.types.EXIT:
		for cont in exit_controlls:
			cont.show()
		object_data_selected(map_editor.selected_object.extra_data)
	else:
		for cont in exit_controlls:
			cont.hide()

func _on_select_data_bt_pressed() -> void:
	file_state = file_states.OBJECT_DATA
	%FileDialog.file_mode = FileDialog.FileMode.FILE_MODE_OPEN_FILE
	%FileDialog.popup()

func object_data_selected(path : String):
	if path == "":
		return
	map_editor.selected_object.extra_data = path
	%Data_name.text = get_path_file_name(path)

func get_path_file_name(path : String) -> String:
	var id : int = path.find(".tres")
	while path[id] != "/":
		id -= 1
	var st : String = path.substr(id+1, -1)
	st = st.erase(st.find("."), 9999)
	return st.substr(0, st.find("."))

var magic_cost : float
func _on_magic_cost_text_changed(new_text: String) -> void:
	if new_text.is_valid_float():
		magic_cost = new_text.to_float()
		return

func _on_next_map_bt_pressed() -> void:
	file_state = file_states.NEXT
	%FileDialog.file_mode = FileDialog.FileMode.FILE_MODE_OPEN_FILE
	%FileDialog.popup()

var next_map_path : String
func next_map_selected(path : String):
	if path == "":
		return
	next_map_path = path
	%next_map_lb.text = get_path_file_name(path)

func _on_rot_stage_item_selected(index: int) -> void:
	selected_enemy_data.rot_stage = index





#
