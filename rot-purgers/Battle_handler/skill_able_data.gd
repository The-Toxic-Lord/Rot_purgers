extends Resource

class_name Skill_able_data

@export var skill : Skill_base
@export var used_position : Vector2i
@export var dir : Map_generator.directions
@export var damage_cells : Array[Vector2i]
@export var targets : Array[Vector2i] = []
@export var enemy_targets : Array[Vector2i] = []
@export var move_cells : Array[Vector2i] = []

@export var target_cell : Vector2i
