extends Resource

class_name Game_save

enum save_types { BATTLE, DIALOGUE }

@export_storage var map_data : Map_data
@export_storage var terrain_map : Dictionary[Vector2i, Terrain_data]
@export_storage var object_map : Dictionary[Vector2i, Map_object]
@export_storage var char_data : Array[Save_char_data] = []
@export_storage var orders : Array[Order_data]
@export_storage var ally_team : Array[Character_stats]
@export_storage var current_map_id : int = 0
@export_storage var modified_cells : Dictionary[Vector2i, float] = {}
@export_storage var dead_chars : Array[String] = []
@export_storage var char_mods : Dictionary[String, Char_mods] = {}

func make_save_char_data():
	char_data.clear()
	for char_node in BattleHandler.allies:
		var save_char_data := Save_char_data.new()
		save_char_data.make(char_node)
		char_data.append(save_char_data)
	for char_node in BattleHandler.enemies:
		var save_char_data := Save_char_data.new()
		save_char_data.make(char_node)
		char_data.append(save_char_data)

func make_save():
	map_data = ObjectLink.map_gen.map_data
	terrain_map = BattleHandler.map_gen.terrain_map
	object_map = BattleHandler.map_gen.object_map
	orders = BattleHandler.order_array
	ally_team = GlobalData.ally_team
	current_map_id = BattleHandler.map_gen.get_parent().current_map_id
	
	for cell in ObjectLink.map_gen.map_cells:
		if ObjectLink.map_gen.map_cells[cell].position.y != ObjectLink.map_gen.terrain_map[cell].height * 0.1:
			modified_cells[cell] = ObjectLink.map_gen.map_cells[cell].position.y
	
	dead_chars = GlobalData.dead_chars
	char_mods = GlobalData.char_mods
	
	await make_save_char_data()
	#await make_screen()
	save_type = save_types.BATTLE

@export_storage var save_type : save_types
@export_storage var save_name : String = "Save_000"
@export_storage var screenshot : Texture2D

func make_screen():
	if ObjectLink.map_gen != null:
		ObjectLink.map_gen.hide_map_ui()
	else:
		DialogueBalloon.hide()
	ObjectLink.save_menu.hide()
	await ObjectLink.get_tree().create_timer(0.1).timeout
	var image = GlobalData.get_viewport().get_texture().get_image()
	image.resize(320, 180)
	screenshot = ImageTexture.create_from_image(image)
	if ObjectLink.map_gen != null:
		ObjectLink.map_gen.show_map_ui()
	else:
		DialogueBalloon.show()
	ObjectLink.save_menu.show()

@export_storage var line_id : String
@export_storage var cutscene_path : String

func make_dialogue_save():
	line_id = DialogueBalloon.dialogue_line.id
	cutscene_path = ObjectLink.cutscene.scene_file_path
	save_type = save_types.DIALOGUE
	#await make_screen()








#
