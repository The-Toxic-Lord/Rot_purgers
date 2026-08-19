@tool extends Resource

class_name Text_data

@export var add_new_line : bool = false:
	set(value):
		new_line()

@export_tool_button("Print dialogue") var bt = print_dial

@export_range(0, 1, 1) var char_id : float = 0
@export var character_names : Array[String] = []
@export var lines : Array[Line_data] = []
@export var cutscene : PackedScene
@export var music : AudioStream

func new_line():
	var new_l := Line_data.new()
	new_l.char_name = character_names[int(char_id)]
	lines.append(new_l)

func print_dial():
	for line in lines:
		print(line.char_name + " : " + line.text)
