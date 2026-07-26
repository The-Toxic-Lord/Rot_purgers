extends MarginContainer

class_name Skill_select_menu

signal skill_selected
signal exit

var skill_slots : Array[Skill_slot] = []

func load_skills(ch_node : Character_node):
	for skill in ch_node.stats.skills:
		var skill_slot : Skill_slot = load("uid://dr6rxsokl8m6c").instantiate()
		%Skill_box.add_child(skill_slot)
		skill_slot.set_skill(skill, ch_node.stats.magic)
		skill_slot.skill_selected.connect(skill_selected.emit.bind(skill))
		skill_slots.append(skill_slot)
	%Skill_box.move_child(%Exit, %Skill_box.get_children().size() - 1)

func clear_skills():
	for skill_slot in skill_slots:
		skill_slot.queue_free()
	skill_slots.clear()

func _on_exit_pressed() -> void:
	exit.emit()

func focus():
	if !skill_slots.is_empty():
		skill_slots[0].focus()






#
