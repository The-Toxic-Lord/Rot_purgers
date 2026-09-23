extends Skill_animation_3d

class_name Plasma_orb_animation

@onready var player: AnimationPlayer = %Player
@onready var plasma_orb: Magic_orb_VFX = %Plasma_orb
@onready var explosion: VFXExplosionBB = %Explosion

func start(target : Vector3):
	plasma_orb.scale = Vector3.ZERO
	plasma_orb.show()
	var tween := create_tween()
	tween.tween_property(plasma_orb, "scale", Vector3(1,1,1), 1.0)
	tween.tween_callback(send.bind(target))

func send(target : Vector3):
	await get_tree().create_timer(0.5).timeout
	var tween := create_tween()
	tween.tween_property(plasma_orb, "global_position", target, 0.5)
	tween.tween_callback(explode)

func explode():
	plasma_orb.hide()
	explosion.position = plasma_orb.position
	explosion.play()
	await explosion.finished
	animation_finished.emit()
