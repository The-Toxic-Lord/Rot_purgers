extends CanvasLayer

class_name Save_menu

var saves_path : String = "user://saves/"
@onready var add_save_bt: Button = %Add_save_bt
@onready var saves_box: GridContainer = %Saves_box

var save_name_to_slot : Dictionary[String, Save_slot] = {}

signal load_save(save : Game_save)

func _ready() -> void:
	ObjectLink.save_menu = self
	populate_menu()

func populate_menu():
	if !DirAccess.dir_exists_absolute(saves_path):
		DirAccess.make_dir_absolute(saves_path)
		return
	var dir := DirAccess.open(saves_path)
	var files : PackedStringArray = dir.get_files()
	var file_dates : Dictionary[int, String] = {}
	for file in files:
		var date : int = FileAccess.get_modified_time(saves_path + file)
		file_dates[date] = file
	var dates : Array[int] = file_dates.keys().duplicate()
	dates.sort()
	for date in dates:
		var file : String = file_dates[date]
		var save = ResourceLoader.load(saves_path + file)
		if save is Game_save:
			add_new_save(save)

func delete_save(save_name : String):
	var file_name : String = save_name + ".tres"
	save_name_to_slot[save_name].queue_free()
	save_name_to_slot.erase(save_name)
	var dir := DirAccess.open(saves_path)
	dir.remove(file_name)

func add_new_save(save : Game_save):
	var save_slot : Save_slot = preload("uid://baqggypr4tsfn").instantiate()
	save_slot.load_data(save)
	saves_box.add_child(save_slot)
	save_slot.load.connect(load_save.emit)
	save_slot.delete.connect(delete_save)
	save_slot.overwrite.connect(overwrite_save)
	saves_box.move_child(save_slot, 1)
	save_name_to_slot[save.save_name] = save_slot

var temp_save : Game_save
func _on_add_save_bt_pressed(overwrite : bool = false) -> void:
	if ObjectLink.map_ui != null:
		temp_save = await ObjectLink.map_ui.make_save()
	elif ObjectLink.cutscene != null:
		temp_save = Game_save.new()
		await temp_save.make_dialogue_save()
	if !overwrite:
		%Save_name_box.show()

func name_submited(over_name : String = ""):
	if over_name == "":
		temp_save.save_name = %Name_edit.text
	else:
		temp_save.save_name = over_name
	await temp_save.make_screen()
	if save_name_to_slot.has(temp_save.save_name):
		save_name_to_slot[temp_save.save_name].queue_free()
	add_new_save(temp_save)
	ResourceSaver.save(temp_save, saves_path + temp_save.save_name + ".tres")
	%Save_name_box.hide()

func _on_back_bt_pressed() -> void:
	hide()

func _on_back_name_bt_pressed() -> void:
	%Save_name_box.hide()

func overwrite_save(save_name : String):
	await _on_add_save_bt_pressed(true)
	name_submited(save_name)
	saves_box.move_child(save_name_to_slot[save_name], 1)







#
