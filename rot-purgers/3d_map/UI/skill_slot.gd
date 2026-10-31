extends MarginContainer

class_name Skill_slot

var skill : Skill_base

signal skill_selected
signal skill_focused
@onready var skill_button: Button = %Skill_button


func set_skill(_skill : Skill_base, magic_left : int):
	skill = _skill
	%Skill_name.text = skill.name
	var skill_cost : int
	if BattleHandler.map_gen.map_data != null:
		skill_cost = int(GlobalData.map_magic_cost_adjustment * skill.magic_cost)
	else:
		skill_cost = int(skill.magic_cost)
	%Skill_cost.text = str(skill_cost)
	if skill_cost > magic_left:
		%Skill_button.disabled = true
		self.modulate = Color("505050")
	
	skill_button.focus_entered.connect(skill_focused.emit.bind(skill.desctiption))
	#skill_button.mouse_entered.connect(skill_focused.emit.bind(skill.desctiption))
	skill_button.mouse_entered.connect(skill_button.grab_focus)

func focus():
	%Skill_button.grab_focus()

func _on_skill_button_pressed() -> void:
	skill_selected.emit()

func get_button():
	return %Skill_button






#
