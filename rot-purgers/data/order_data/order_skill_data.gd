extends Order_data

class_name Order_skill_data

@export var skill : Skill_base
@export var damage_cells : Array[Vector2i]
@export var move_cells : Array[Vector2i]
@export var selected_cell : Vector2i
@export var move_target : Vector2i

func make_skill(_attacker : Character_node, _skill : Skill_base, 
_damage_cells : Array[Vector2i], _move_cells : Array[Vector2i], _selected_cell : Vector2i) -> void:
	attacker = _attacker.get_path()
	skill = _skill
	damage_cells = _damage_cells
	move_cells = _move_cells
	selected_cell = _selected_cell
	#print(move_cells)
	if skill.move_mode != Skill_base.move.NONE:
		#var move_cell : Array[Vector2i] = [skill.skill_map.move_target + _attacker.map_pos]
		#var target_m : Array[Vector2i] = ObjectLink.enemy_manager.rotare_skill_cells_around_position(
			#move_cell, _attacker.map_pos, _attacker.current_direction)
		move_target = move_cells[0]
