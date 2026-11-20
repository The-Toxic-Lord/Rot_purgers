extends Map_UI

var execution_check := false

func _on_turn_menu_execute() -> void:
	super()
	execution_check = true

var terrain_spell_mod_used := false
var protection_skill_selected := false
var heal_used := false

func _on_spell_select_menu_skill_selected(skill : Skill_base) -> void:
	super(skill)
	match skill.skill_type:
		Skill_base.skill_types.TERRAIN:
			terrain_spell_mod_used = true
		Skill_base.skill_types.PROTECT:
			protection_skill_selected = true
		Skill_base.skill_types.HEAL:
			heal_used = true


var rearrange_used := false
func _on_char_action_menu_rearange() -> void:
	super()
	rearrange_used = true

func _on_rearange_menu_confirm() -> void:
	super()
	rearrange_used = true

func _on_char_action_menu_boost() -> void:
	super()
	rearrange_used = true
