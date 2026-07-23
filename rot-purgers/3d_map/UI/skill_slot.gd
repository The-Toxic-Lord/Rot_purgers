extends MarginContainer

class_name Skill_slot

var skill : Skill_base

signal skill_selected

func set_skill(_skill : Skill_base):
	skill = _skill
	%Skill_name.text = skill.name
	%Skill_cost.text = str(skill.magic_cost)

func focus():
	%Skill_button.grab_focus()

func _on_skill_button_pressed() -> void:
	skill_selected.emit()
