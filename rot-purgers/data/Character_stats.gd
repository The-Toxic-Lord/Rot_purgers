extends Resource

class_name Character_stats


@export var name := "rename me"
@export var char_class := "class"
@export var age := 20
@export var sprite : Texture2D

@export var max_health := 100
@export_storage var health : int
@export var max_magic := 100
@export_storage var magic : int
@export var strength : int = 10
@export var defence : int = 5
@export var magic_strenght : int = 10
@export var accuracy : int = 10
@export var speed : int = 5

@export var move_speed : int = 4
@export var jump_height : int = 20
@export var attack_distance : int = 1
@export var counter : int = 1

@export_storage var atlas_coords : Vector2i

func new() -> void:
	health = max_health
	magic = max_magic











#
