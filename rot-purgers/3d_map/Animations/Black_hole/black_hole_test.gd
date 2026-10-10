extends Skill_animation_3d

@onready var anim: AnimationPlayer = %AnimationPlayer
@export var sfx : AudioStream

@warning_ignore("unused_parameter")
func start(target : Vector3, cells : Array[Vector2i] = []) -> void:
	global_position = target
	anim.play("Main")
	SoundHandler.play_sfx(sfx)
	await anim.animation_finished
	animation_finished.emit()
