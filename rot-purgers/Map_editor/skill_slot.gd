extends MarginContainer

class_name Map_editor_skill_slot

signal skill_enabled
signal skill_disabled

func set_data(skill_name : String, state : bool):
	%Skill_name.text = skill_name
	%bt.button_pressed = state

func _on_bt_toggled(toggled_on: bool) -> void:
	if toggled_on:
		skill_enabled.emit()
	else:
		skill_disabled.emit()
