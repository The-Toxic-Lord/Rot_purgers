extends Resource

class_name Attack_data

@export var attacker : NodePath
@export var target : NodePath

func _init(_attacker : Character_node, _target : Character_node) -> void:
	attacker = _attacker.get_path()
	target = _target.get_path()
