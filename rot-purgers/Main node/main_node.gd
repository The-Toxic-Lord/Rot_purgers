extends Node

class_name Main_node

var map_editor : Map_editor
var map_generator : Map_generator
var cutscene : Node3D

var background : Node3D

func _on_map_editor_pressed() -> void:
	map_editor = load("uid://cx7jdespo6tsb").instantiate()
	background.queue_free()
	add_child(map_editor)

func generate_map(terrain_map_data : Dictionary[Vector2i, Terrain_data],
 object_map_data : Dictionary[Vector2i, Map_object], enemy_map_data : Dictionary[Vector2i, Character_stats]):
	map_generator = load("uid://buyr0671du0pe").instantiate()
	add_child(map_generator)
	map_editor.queue_free()
	map_generator.start(terrain_map_data, object_map_data, enemy_map_data)

func _on_load_pressed() -> void:
	if ResourceLoader.exists("user://save.tres"):
		map_generator = load("uid://buyr0671du0pe").instantiate()
		background.queue_free()
		add_child(map_generator)
		map_generator.load_save()
		%Main_menu.hide_menu()

func remove_background():
	background.queue_free()

var current_map_id : int = -1
func load_map(id : int = -1):
	if id == 0:
		remove_background()
	if current_map_id + 1 == GlobalData.map_data_path.size():
		%Main_menu.on_victory()
		return
	if id == -1:
		current_map_id += 1
	else:
		current_map_id = id
	var map_data = load(GlobalData.map_data_path[current_map_id])
	if map_data is Map_data:
		var new_map_gen : Map_generator = load("uid://buyr0671du0pe").instantiate()
		new_map_gen.hide()
		add_child(new_map_gen)
		new_map_gen.load_map(map_data)
		await new_map_gen.map_loaded
		if map_generator != null:
			map_generator.queue_free()
		if cutscene != null:
			cutscene.queue_free()
		map_generator = new_map_gen
		map_generator.show()
		if map_data.music != null:
			SoundHandler.play_music(map_data.music)
	elif map_data is PackedScene:
		var new_cutscene : Cutscene = map_data.instantiate()
		add_child(new_cutscene)
		if map_generator != null:
			map_generator.queue_free()
		if cutscene != null:
			cutscene.queue_free()
		cutscene = new_cutscene
		cutscene.start_cutscene()
		#if map_data.music != null:
			#SoundHandler.play_music(map_data.music)

func load_background():
	background = load("uid://cc2fywiyu0mah").instantiate()
	add_child(background)
	SoundHandler.play_menu()

func show_menu():
	%Main_menu.show_menu()

func _ready() -> void:
	BattleHandler.main_node = self
	load_background()

func game_over():
	%Main_menu.on_game_over()
	current_map_id = -1

func close_map():
	if map_generator != null:
		map_generator.queue_free()
	if cutscene != null:
		cutscene.queue_free()

func load_tutorial():
	var map_data = load("res://map_data_res/tutorial.tres")
	var new_map_gen : Tutorial = load("uid://2imm1twj3hd").instantiate()
	new_map_gen.hide()
	add_child(new_map_gen)
	new_map_gen.load_map(map_data)
	await new_map_gen.map_loaded
	remove_background()
	if map_generator != null:
		map_generator.queue_free()
	map_generator = new_map_gen
	map_generator.show()
	SoundHandler.play_tutor()




#
