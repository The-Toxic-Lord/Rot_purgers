extends Resource

class_name Character


@export var name := "rename me"
@export var char_class := "class"
@export var age := 20
@export var sprite : Texture2D

@export var max_health := 100.0
@export_storage var health : float
@export var max_magic := 100.0
@export_storage var magic : float
@export var strength : int = 10
@export var defence : int = 5
@export var magic_strenght : int = 10
@export var accuracy : int = 10
@export var speed : int = 5

@export var move_speed : int = 4
@export var jump_height : int = 20

func _init() -> void:
	health = max_health
	magic = max_magic












#
