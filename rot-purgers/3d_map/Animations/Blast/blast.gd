extends Skill_animation_3d

@onready var hits : Array[VFXImpactBB] = [
	%VFXImpactSmall_02, %VFXImpactSmall_03, %VFXImpactSmall_04
]

@export var sfx : AudioStream

func start(target : Vector3, cells : Array[Vector2i] = []) -> void:
	await get_tree().process_frame
	var y : float = target.y
	for i in hits.size():
		var pos : Vector3 = Vector3(cells[i].x * 2.0, y, cells[i].y * 2.0)
		hits[i].global_position = pos
		hits[i].play()
	SoundHandler.play_sfx(sfx)
	await get_tree().create_timer(0.5).timeout
	animation_finished.emit()
