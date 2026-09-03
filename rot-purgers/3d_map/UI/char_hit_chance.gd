extends HBoxContainer

class_name Char_hit_chance_box

func set_data(char_name : String, chance : int):
	%Char_name.text = char_name + " :"
	%Chance.text = str(chance) + "%"
