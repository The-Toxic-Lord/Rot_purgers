extends MarginContainer

class_name Char_map_editor

signal remove_character

func set_data(char_data : Character_stats):
	%Label.text = char_data.name
	%Button.pressed.connect(remove_character.emit)
