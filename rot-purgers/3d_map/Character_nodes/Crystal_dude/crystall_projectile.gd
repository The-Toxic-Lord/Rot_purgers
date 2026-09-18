extends Node3D

class_name Projectile_3d

func _ready() -> void:
	set_physics_process(false)

var target : Vector3

func start(_target : Vector3):
	target = _target
	set_physics_process(true)

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	look_at(target)










#
