extends Node3D

class_name Weapon_trail

@onready var gpu_trail_3d: GPUTrail3D = %GPUTrail3D


func turn_off():
	hide()
	gpu_trail_3d.length = 0

func turn_on():
	show()
	gpu_trail_3d.length = 60
