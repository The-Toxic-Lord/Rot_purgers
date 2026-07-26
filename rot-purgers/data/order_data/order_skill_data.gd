extends Order_data

class_name Order_skill_data

@export var skill : Skill_base
@export var damage_cells : Array[Vector2i]
@export var move_cells : Array[Vector2i]
@export var selected_cell : Vector2i

func make_skill(_attacker : Character_node, _skill : Skill_base, 
_damage_cells : Array[Vector2i], _move_cells : Array[Vector2i], _selected_cell : Vector2i) -> void:
	attacker = _attacker.get_path()
	skill = _skill
	damage_cells = _damage_cells
	move_cells = _move_cells
	selected_cell = _selected_cell
