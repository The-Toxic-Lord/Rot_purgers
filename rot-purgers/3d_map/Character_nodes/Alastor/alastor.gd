extends Character_node

@warning_ignore("unused_parameter")
func animate_skill(skill_node : Skill_animation_3d):
	char_animation.play("Spell_UP_2")
	await char_animation.animation_finished
	char_animation.play("Spell_UP_back")
	await char_animation.animation_finished
	char_animation.play("Idle")

func skill_windup():
	char_animation.play("Spell_UP_1")
	await char_animation.animation_finished
