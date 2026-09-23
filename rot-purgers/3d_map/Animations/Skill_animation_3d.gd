extends Node3D

class_name Skill_animation_3d

signal animation_finished

func _ready() -> void:
	animation_finished.connect(kill)

func start(target : Vector3) -> void:
	pass

func kill():
	queue_free()
