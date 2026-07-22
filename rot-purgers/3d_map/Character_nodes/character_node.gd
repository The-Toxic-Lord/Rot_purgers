extends Node3D

class_name Character_node

@export var stats : Character_stats

@export var can_move := true
@export var can_attack := true
var map_pos : Vector2i

signal move_finished

func end_round():
	can_move = true
	can_attack = true

func damage(value : float):
	stats.health = clampi(stats.health - int(value), 0, stats.max_health)
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
	path.remove_at(0)
	for cell in path:
		await move_next(cell, terrain_map, map_cells)
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



#
