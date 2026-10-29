extends Node

class_name Global_data

@export var ally_team : Array[Character_stats] = []
@export var enemy_data : Array[Character_stats]

@export var map_data_path : Array[String] = []

@export var map_magic_cost_adjustment : float

var dir_to_vect : Dictionary[Map_generator.directions, Vector2i] = {
	Map_generator.directions.N : Vector2i(0, -1),
	Map_generator.directions.S : Vector2i(0, 1),
	Map_generator.directions.E : Vector2i(1, 0),
	Map_generator.directions.W : Vector2i(-1, 0)
}
var oposing_dir : Dictionary[Map_generator.directions, Map_generator.directions] = {
	Map_generator.directions.N : Map_generator.directions.S,
	Map_generator.directions.S : Map_generator.directions.N,
	Map_generator.directions.E : Map_generator.directions.W,
	Map_generator.directions.W : Map_generator.directions.E
}
var neighbors_sides : Array[Vector2i] = [
	Vector2i.UP,
	Vector2i.RIGHT,
	Vector2i.DOWN,
	Vector2i.LEFT,
]

@export var dead_chars : Array[String] = []

func clear_data():
	ally_team.clear()
	dead_chars.clear()

@export var char_mods : Dictionary[String, Char_mods] = {}

func mod_char(char_name : String, add_skill : Skill_base = null, 
change_property : String = "", property_value = null):
	if !char_mods.has(char_name):
		char_mods[char_name] = Char_mods.new()
	if add_skill != null:
		char_mods[char_name].add_skills.append(add_skill)
	if change_property != "":
		char_mods[char_name].changed_properties[change_property] = property_value

func apply_char_mods():
	for char_name in char_mods:
		var char_mod : Char_mods = char_mods[char_name]
		var char_stats : Character_stats = null
		for ally in ally_team:
			if ally.name == char_name:
				char_stats = ally
				break
		if char_stats == null:
			continue
		for skill in char_mod.add_skills:
			char_stats.skills.append(skill)
		for prop in char_mod.changed_properties.keys():
			char_stats.set(prop, char_mod.changed_properties[prop])

func load_save(save : Game_save):
	ally_team = save.ally_team
	dead_chars = save.dead_chars
	map_magic_cost_adjustment = save.map_data.magic_cost_adjustment
	char_mods = save.char_mods

@export var char_pictures : Dictionary[String, Texture2D]






#
