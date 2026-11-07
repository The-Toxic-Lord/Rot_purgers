extends Character_node

func move_normal(pos : Vector3, time := 0.5):
	var tween := create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(self, "position", pos, time)
	if char_animation.has_animation("Fly"):
		if char_animation.current_animation != "Fly":
			char_animation.play("Fly")
	await tween.finished




#
