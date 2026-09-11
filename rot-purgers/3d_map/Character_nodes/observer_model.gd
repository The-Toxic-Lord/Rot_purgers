extends Node3D

class_name Observer_model

@onready var eyes : Array[MeshInstance3D] = [
	%Eye_top, %Eye_forward, %Eye_back, %Eye_left, %Eye_right
]

var start_quat : Array[Quaternion] = []
var target_quat : Dictionary[MeshInstance3D, Quaternion] = {}
@export var angle_max : float = 60
@export var eye_speed : float = 1.0
var eye_tweens : Dictionary[MeshInstance3D, Tween] = {}

func _ready() -> void:
	for eye in eyes:
		start_quat.append(eye.quaternion)
		rotate_eye(eye)

func get_new_angle(eye : MeshInstance3D) -> Quaternion:
	var q1 := Quaternion(Vector3.UP, randf_range(-PI/4, PI/4))
	var q2 := Quaternion(Vector3.FORWARD, randf_range(-PI/4, PI/4))
	var q3 := Quaternion(Vector3.RIGHT, randf_range(-PI/4, PI/4))
	var id : int = eyes.find(eye)
	var q : Quaternion = q1 * q2 * q3 * start_quat[id]
	return q

func rotate_eye(eye : MeshInstance3D):
	target_quat[eye] = get_new_angle(eye)
	var rot_time : float = target_quat[eye].angle_to(eye.quaternion) / eye_speed
	var tween := create_tween()
	eye_tweens[eye] = tween
	tween.tween_property(eye, "quaternion", target_quat[eye], rot_time)
	tween.tween_callback(rotate_eye.bind(eye))








#
