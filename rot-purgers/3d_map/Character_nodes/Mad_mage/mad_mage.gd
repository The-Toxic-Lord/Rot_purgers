extends Character_node

func animate_skill(skill_node : Skill_animation_3d):
	await skill_node.animation_finished
	char_animation.play("Spell_back")
	await char_animation.animation_finished
	char_animation.play("Idle")

func skill_windup():
	char_animation.play("Spell_windup")
	await char_animation.animation_finished
