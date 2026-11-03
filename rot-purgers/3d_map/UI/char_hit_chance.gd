extends HBoxContainer

class_name Char_hit_chance_box

func set_data(char_name : String, chance : int):
	%Char_name.text = char_name + " :"
	%Chance.text = str(chance) + "%"

func lower_font():
	var char_name: Label = %Char_name
	char_name.add_theme_font_size_override("font_size", 26)
	var chance: Label = %Chance
	chance.add_theme_font_size_override("font_size", 26)
