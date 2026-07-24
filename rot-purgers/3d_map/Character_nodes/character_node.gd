extends Node3D

class_name Character_node

@export var stats : Character_stats

var can_move := true
var can_attack := true
var is_defending := false
var has_order := false
var map_pos : Vector2i

var previous_direction : Map_generator.directions = Map_generator.directions.N
var current_direction : Map_generator.directions = Map_generator.directions.N
var move_to_direction: Dictionary[Vector2i, Map_generator.directions] = {
	Vector2i(0, -1) : Map_generator.directions.N,
	Vector2i(0, 1) : Map_generator.directions.S,
	Vector2i(1, 0) : Map_generator.directions.E,
	Vector2i(-1, 0) : Map_generator.directions.W
}
var dir_to_angle : Dictionary[Map_generator.directions, float] = {
	Map_generator.directions.N : 0.0,
	Map_generator.directions.E : -PI/2,
	Map_generator.directions.W : PI/2,
	Map_generator.directions.S : PI
}
signal direction_changed

signal move_finished
signal attack_finished

func new_round():
	can_move = true
	can_attack = true
	is_defending = false

func damage(value : float):
	stats.health = clampi(stats.health - int(value), 0, stats.max_health)
	%Damage_numbers.text = str(int(value))
	display_damage()

func display_damage():
	%Damage_numbers.show()
	await get_tree().create_timer(1).timeout
	%Damage_numbers.hide()
	if stats.health == 0:
		BattleHandler.enemy_dies(self)

func move(target_cell : Vector2i, terrain_map : Dictionary[Vector2i, Terrain_data],
select_zones : Array[Vector2i], map_boundary : Rect2i, map_cells : Dictionary[Vector2i, Map_cell]):
	var a_star := AStarGrid2D.new()
	a_star.region = map_boundary
	a_star.cell_size = Vector2i(1,1)
	a_star.default_compute_heuristic = AStarGrid2D.HEURISTIC_CHEBYSHEV
	a_star.default_estimate_heuristic = AStarGrid2D.HEURISTIC_CHEBYSHEV
	a_star.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	a_star.update()
	
	a_star.fill_solid_region(a_star.region)
	for cell in select_zones:
		a_star.set_point_solid(cell, false)
	for ally in BattleHandler.allies:
		a_star.set_point_solid(ally.map_pos, false)
	a_star.update()
	
	var path : Array[Vector2i] = a_star.get_id_path(map_pos, target_cell)
	var prev_pos : Vector2i = map_pos
	path.remove_at(0)
	for cell in path:
		previous_direction = current_direction
		turn(move_to_direction[cell - prev_pos])
		current_direction = move_to_direction[cell - prev_pos]
		await move_next(cell, terrain_map, map_cells)
		prev_pos = map_pos
	move_finished.emit()

func move_next(target_cell : Vector2i, terrain_map : Dictionary[Vector2i, Terrain_data],
map_cells : Dictionary[Vector2i, Map_cell]):
	if terrain_map[map_pos].height == terrain_map[target_cell].height:
		await move_normal(map_cells[target_cell].position)
	else:
		var height : int = terrain_map[target_cell].height - terrain_map[map_pos].height
		if height > 0 and height <= 5:
			await move_step(map_cells[target_cell].position)
		elif height > 0:
			await move_jump(map_cells[target_cell].position)
		else:
			await move_drop(map_cells[target_cell].position)
	map_pos = target_cell

func move_normal(pos : Vector3):
	var tween := create_tween()
	tween.tween_property(self, "position", pos, 0.5)
	await tween.finished

func move_step(pos : Vector3):
	var ap : AnimationPlayer = $AnimationPlayer
	var anim := ap.get_animation("move_step")
	anim.track_set_key_value(0, 0, position)
	var dir : Vector3 = pos - position
	var step : Vector3 = Vector3(position.x + dir.x / 2.0, position.y, position.z + dir.z / 2.0)
	anim.track_set_key_value(0, 1, step)
	step.y += dir.y
	anim.track_set_key_value(0, 2, step)
	anim.track_set_key_value(0, 3, pos)
	ap.play("move_step")
	await ap.animation_finished

func move_jump(pos : Vector3):
	var ap : AnimationPlayer = $AnimationPlayer
	var anim := ap.get_animation("move_jump")
	anim.track_set_key_value(0, 0, position)
	var dir : Vector3 = pos - position
	var step : Vector3 = position + Vector3(dir.x * 0.25, dir.y, dir.z * 0.25)
	anim.track_set_key_value(0, 1, step)
	step = position + Vector3(dir.x * 0.75, dir.y + 0.5, dir.z * 0.75)
	anim.track_set_key_value(0, 2, step)
	anim.track_set_key_value(0, 3, pos)
	ap.play("move_jump")
	await ap.animation_finished

func move_drop(pos : Vector3):
	var ap : AnimationPlayer = $AnimationPlayer
	var anim := ap.get_animation("move_jump")
	anim.track_set_key_value(0, 0, position)
	var dir : Vector3 = pos - position
	var step : Vector3 = position + Vector3(dir.x * 0.25, 0.5, dir.z * 0.25)
	anim.track_set_key_value(0, 1, step)
	step = position + Vector3(dir.x * 0.75, 0, dir.z * 0.75)
	anim.track_set_key_value(0, 2, step)
	anim.track_set_key_value(0, 3, pos)
	ap.play("move_jump")
	await ap.animation_finished

func defend():
	can_attack = false
	can_move = false
	is_defending = true

func turn(new_dir : Map_generator.directions):
	if new_dir == current_direction:
		return
	previous_direction = current_direction
	current_direction = new_dir
	
	rotation.y = dir_to_angle[new_dir]
	
	await get_tree().process_frame
	direction_changed.emit()

func heal(value : float):
	stats.health = clampi(stats.health + int(value), 0, stats.max_health)

func _ready() -> void:
	%temp_anim.play("Idle")

func attack(target_cell : Vector2i):
	turn_to_target(target_cell)
	await get_tree().process_frame
	attack_finished.emit()

func skill(target_cell : Vector2i):
	turn_to_target(target_cell)
	await get_tree().process_frame
	attack_finished.emit()

var dir_to_vector : Dictionary[Map_generator.directions, Vector2i] = {
	Map_generator.directions.N : Vector2i(0, -1),
	Map_generator.directions.S : Vector2i(0, 1),
	Map_generator.directions.E : Vector2i(1, 0),
	Map_generator.directions.W : Vector2i(-1, 0)
}
var dir_arr : Array[Map_generator.directions] = [
	Map_generator.directions.N, Map_generator.directions.E, 
	Map_generator.directions.S, Map_generator.directions.W]

func turn_to_target(target_cell : Vector2i):
	var angle : float
	var dir : Vector2 = (target_cell - map_pos)
	dir = dir.normalized()
	angle = dir.angle_to(dir_to_vector[current_direction])
	angle = rad_to_deg(angle)
	if angle > -50 and angle < 50:
		return
	var id : int = dir_arr.find(current_direction)
	var new_dir : Map_generator.directions
	if angle > 50 and angle < 140:
		if id == 0:
			id = 4
		new_dir = dir_arr[id - 1]
	elif angle < -50 and angle > -140:
		if id == 3:
			id = -1
		new_dir = dir_arr[id + 1]
	else:
		if id >= 2:
			id -= 4
		new_dir = dir_arr[id + 2]
	turn(new_dir)









#
