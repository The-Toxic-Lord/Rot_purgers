extends Resource

class_name Order_data

@export var attacker : NodePath
@export var target : NodePath


func make(_attacker : Character_node, _target : Character_node) -> void:
	attacker = _attacker.get_path()
	target = _target.get_path()
