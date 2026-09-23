extends Skill_animation_3d

@onready var anim: AnimationPlayer = %AnimationPlayer
@export var sfx : AudioStream

func start(target : Vector3) -> void:
	global_position = target
	anim.play("Main")
	SoundHandler.play_sfx(sfx)
	await anim.animation_finished
	animation_finished.emit()
