extends Resource

class_name Game_save

@export_storage var map_data : Map_data
@export_storage var terrain_map : Dictionary[Vector2i, Terrain_data]
@export_storage var object_map : Dictionary[Vector2i, Map_object]
@export_storage var char_data : Array[Save_char_data] = []
@export_storage var orders : Array[Order_data]
@export_storage var ally_team : Array[Character_stats]
@export_storage var current_map_id : int = 0
@export_storage var modified_cells : Dictionary[Vector2i, float] = {}
@export_storage var dead_chars : Array[String] = []

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
	
	await make_save_char_data()











#
