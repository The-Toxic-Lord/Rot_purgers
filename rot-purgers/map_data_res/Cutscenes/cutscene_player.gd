extends AnimationPlayer

func _play(anim_name : String, wait := false):
	play(anim_name)
	if wait:
		await animation_finished
