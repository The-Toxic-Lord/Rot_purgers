extends Node3D

class_name Skill_animation_3d

signal animation_finished

func _ready() -> void:
	animation_finished.connect(kill)

@warning_ignore("unused_parameter")
func start(target : Vector3, cells : Array[Vector2i] = []) -> void:
	pass

func kill():
	queue_free()
