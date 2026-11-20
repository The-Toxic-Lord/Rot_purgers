extends Skill_animation_3d

@export var sfx : AudioStream

func start(target : Vector3, cells : Array[Vector2i] = []) -> void:
	await get_tree().process_frame
	var y : float = target.y
	for i in 3:
		var explosion : VFXImpactBB = preload("uid://dp6fn641cy82u").instantiate()
		add_child(explosion)
		var pos : Vector3 = Vector3(cells[i].x * 2.0, y, cells[i].y * 2.0)
		explosion.global_position = pos
		explosion.play()
	SoundHandler.play_sfx(sfx)
	projectile_send.emit()
	await get_tree().create_timer(0.5).timeout
	animation_finished.emit()
