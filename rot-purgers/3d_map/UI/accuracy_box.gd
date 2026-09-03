extends MarginContainer


class_name Accuracy_box

func update_data(attacker : Character_stats, 
targets : Array[Character_stats], skill : Skill_base = null):
	await clear_box()
	for target in targets:
		var char_hit_box : Char_hit_chance_box = load("uid://d0nk5hmontt30").instantiate()
		%Box.add_child(char_hit_box)
		var chance : float = float(attacker.accuracy)/float(target.speed)
		if skill != null:
			chance += skill.accuracy_modifier
		char_hit_box.set_data(target.name, clamp(round(chance * 100), 0, 100))

func clear_box():
	var ch : Array[Node] = %Box.get_children()
	for i in ch.size():
		if i != 0:
			ch[i].queue_free()












#
