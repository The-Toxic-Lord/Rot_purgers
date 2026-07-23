extends Order_data

class_name Order_heal

@export var skill : Skill_base

func _init(_attacker : Character_node, _skill : Skill_base) -> void:
	attacker = _attacker.get_path()
	skill = _skill
