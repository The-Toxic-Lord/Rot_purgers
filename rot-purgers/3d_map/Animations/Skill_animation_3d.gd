class_name Skill_animation_3d extends Node3D

signal animation_finished

func _ready() -> void:
	animation_finished.connect(kill)

@warning_ignore("unused_parameter")
func start(target : Vector3, cells : Array[Vector2i] = []) -> void:
	animation_finished.emit()

func kill():
	queue_free()
