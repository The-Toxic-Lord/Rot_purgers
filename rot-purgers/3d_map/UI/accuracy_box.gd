extends MarginContainer


class_name Accuracy_box

var char_hit_box_scene : PackedScene

func _ready() -> void:
	char_hit_box_scene = load("uid://d0nk5hmontt30")

func update_data(attacker : Character_stats, 
targets : Array[Character_stats], skill : Skill_base = null):
	await clear_box()
	for target in targets:
		var char_hit_box : Char_hit_chance_box = char_hit_box_scene.duplicate(true).instantiate()
		%Box.add_child(char_hit_box)
		var chance : float = float(attacker.accuracy)/float(target.speed)
		if skill != null:
			chance += skill.accuracy_modifier
		char_hit_box.set_data(target.name, clamp(round(chance * 100), 0, 100))
		if chance > 1.0 and skill == null:
			var dmg_bonus : float = 1.0 + (chance - 1.0) / 2.0
			var dmg_bonus_box : Char_hit_chance_box = char_hit_box_scene.duplicate(true).instantiate()
			%Box.add_child(dmg_bonus_box)
			dmg_bonus_box.lower_font()
			dmg_bonus_box.set_data("Acc dmg bonus", round(dmg_bonus * 100))

func clear_box():
	var ch : Array[Node] = %Box.get_children()
	for i in ch.size():
		if i != 0:
			ch[i].queue_free()












#
