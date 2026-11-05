extends MarginContainer

class_name Skill_desctiption_UI

@onready var description_lb: Label = %Description_lb
@onready var desc_box: VBoxContainer = %Desc_box


func update(skill : Skill_base = null, text : String = ""):
	show()
	if skill == null:
		description_lb.text = text
		return
	
	description_lb.text = skill.desctiption
	match skill.skill_type:
		Skill_base.skill_types.PROTECT:
			description_lb.text += "\n" + "Max height difference : " +\
			 str(skill.max_height_difference) + " | Deflect number : " +\
			str(skill.deflect_times)
		Skill_base.skill_types.ATTACK:
			description_lb.text += "\n" + "Max height difference : " +\
			 str(skill.max_height_difference)
			if skill.accuracy_modifier != 0.0:
				description_lb.text += " | " + "Accuracy mod : "
				if skill.accuracy_modifier > 0:
					description_lb.text += "+"
				else:
					description_lb.text += "-"
				description_lb.text += str(roundi(skill.accuracy_modifier * 100)) + "%"
			if skill.damage != 1.0:
				description_lb.text += " | " + "Power mod : "
				if skill.damage > 1.0:
					description_lb.text += "+"
				else:
					description_lb.text += "-"
				description_lb.text += str(roundi(skill.damage * 100)-100) + "%"
		Skill_base.skill_types.HEAL:
			description_lb.text += "\n" + "Healing strength : " + str(roundi(skill.heal_value * 100)) + "%"



func _hide():
	hide()





#
