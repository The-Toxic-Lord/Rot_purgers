extends Node3D

class_name Character_node

@export var stats : Character_stats
@export var base_stats : Character_stats
@export var material : Material
@export var char_animation : AnimationPlayer
@export var char_model_node : Node3D
@export var skeleton : Skeleton3D
@export var attack_trail : Weapon_trail

var can_move := true
var can_attack := true
var is_defending := false
var has_order := false:
	set(value):
		has_order = value
		if value:
			%Executed_order.show()
		else:
			%Executed_order.hide()
var map_pos : Vector2i
var previous_map_pos : Vector2i
var can_undo_move := false
var is_enemy := true
var car_rearange := true
var is_dead := false
var deflects_left : int = 0

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
signal animation_ended

var mini_char_stats : Mini_char_stats

var rot_stage : Dictionary[int, float] = {
	0 : 0,
	1 : 0.39,
	2 : 0.62,
	3 : 0.77
}
var rot_colors : Dictionary[int, Color] = {
	0 : Color("39bc0000"),
	1 : Color("39bc0063"),
	2 : Color("0083179e"),
	3 : Color("008317c4")
}
func set_rot(stage : int):
	if material is ShaderMaterial:
		material.set_shader_parameter("rot", rot_colors[stage])
	else:
		push_error("wrong material")

func set_stats(char_stat : Character_stats):
	stats = char_stat.duplicate()
	base_stats = char_stat.duplicate()

func _ready() -> void:
	if char_animation.has_animation("Idle"):
		char_animation.play("Idle")
	if skeleton != null:
		for child in skeleton.get_children():
			if child is MeshInstance3D:
				child.set_surface_override_material(0, material)
	if material is ShaderMaterial:
		material.set_shader_parameter("dissolve", -0.1)

func new_round():
	can_move = true
	can_attack = true
	is_defending = false
	can_undo_move = false
	car_rearange = true
	previous_map_pos = Vector2i(-1, -1)
	stats.magic = clampi(stats.magic + int(stats.max_magic * 0.05), 0, stats.max_magic)

func damage(value : float, display_mini := false):
	await get_tree().process_frame
	if value == -1:
		%Damage_numbers.text = "miss"
		%Damage_numbers.modulate = Color("ffffffff")
	else:
		stats.health = clampi(stats.health - int(value), 0, stats.max_health)
		%Damage_numbers.text = str(int(value))
		%Damage_numbers.modulate = Color("e80029")
		if display_mini:
			mini_char_stats.display_damage(stats.health)
	display_damage(display_mini)

func display_damage(display_mini := false):
	%Damage_numbers.show()
	SoundHandler.play_damage()
	if $AnimationPlayer.has_animation("Damage"):
		$AnimationPlayer.play("Damage")
	if char_animation.has_animation("Damage"):
		char_animation.play("Damage")
		await char_animation.animation_finished
		char_animation.play("Idle")
	else:
		await get_tree().create_timer(0.5).timeout
	%Damage_numbers.hide()
	#animation_ended.emit()
	if stats.health == 0:
		is_dead = true
		if display_mini:
			mini_char_stats.play_dead()
		$AnimationPlayer.play("Death")
		await $AnimationPlayer.animation_finished
		animation_ended.emit()
		BattleHandler.char_dies(self)
	else:
		animation_ended.emit()

func move(target_cell : Vector2i, terrain_map : Dictionary[Vector2i, Terrain_data],
select_zones : Array[Vector2i], map_boundary : Rect2i, map_cells : Dictionary[Vector2i, Map_cell]):
	previous_map_pos = map_pos
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
	if BattleHandler.allies.has(self):
		for ally in BattleHandler.allies:
			a_star.set_point_solid(ally.map_pos, false)
	else:
		for enemy in BattleHandler.enemies:
			a_star.set_point_solid(enemy.map_pos, false)
	a_star.update()
	
	var path : Array[Vector2i] = a_star.get_id_path(map_pos, target_cell)
	var prev_pos : Vector2i = map_pos
	
	path.remove_at(0)
	for cell in path:
		previous_direction = current_direction
		turn(move_to_direction[cell - prev_pos], true)
		current_direction = move_to_direction[cell - prev_pos]
		await move_next(cell, terrain_map, map_cells)
		prev_pos = map_pos
	can_undo_move = true
	char_animation.play("Idle")
	move_finished.emit()

func move_next(target_cell : Vector2i, terrain_map : Dictionary[Vector2i, Terrain_data],
map_cells : Dictionary[Vector2i, Map_cell]):
	if terrain_map[map_pos].height == terrain_map[target_cell].height:
		await move_normal(map_cells[target_cell].position)
	else:
		var height : int = terrain_map[target_cell].height - terrain_map[map_pos].height
		if height >=-5 and height <= 5:
			await move_step(map_cells[target_cell].position)
		elif height > 0:
			await move_jump(map_cells[target_cell].position)
		else:
			await move_drop(map_cells[target_cell].position)
	map_pos = target_cell

func move_normal(pos : Vector3):
	var tween := create_tween()
	tween.tween_property(self, "position", pos, 0.5)
	if char_animation.has_animation("Walk"):
		char_animation.play("Walk")
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
	if char_animation.has_animation("Jump_up"):
		await play_jump()
	else:
		ap.play("move_jump")
		await ap.animation_finished
	play_idle()

func play_jump():
	char_animation.play("Crouch_jump_up")
	await char_animation.animation_finished
	$AnimationPlayer.play("move_jump")
	char_animation.play("Jump_up")
	await $AnimationPlayer.animation_finished
	char_animation.play("Land_jump_up")
	await char_animation.animation_finished

func play_idle():
	char_animation.play("Idle")

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
	if char_animation.has_animation("Jump_up"):
		await play_jump_down()
	else:
		ap.play("move_jump")
		await ap.animation_finished
	play_idle()

func play_jump_down():
	char_animation.play("Crouch_jump_down")
	await char_animation.animation_finished
	$AnimationPlayer.play("move_jump")
	char_animation.play("Jump_down")
	await $AnimationPlayer.animation_finished
	char_animation.play("Land_jump_down")
	await char_animation.animation_finished

func defend():
	can_attack = false
	has_order = true
	is_defending = true

func turn(new_dir : Map_generator.directions, skip_animation := false):
	if new_dir == current_direction:
		await get_tree().process_frame
		turn_finished()
		return
	previous_direction = current_direction
	current_direction = new_dir
	
	var q := Quaternion(Vector3.UP, dir_to_angle[new_dir])
	if skip_animation:
		quaternion = q
		await get_tree().process_frame
		turn_finished()
	else:
		var tween := create_tween()
		tween.tween_property(self, "quaternion", q, 0.5)
		tween.tween_callback(turn_finished)

func turn_finished():
	direction_changed.emit()

func heal(value : float):
	var heal_val : int = int(stats.max_health * value)
	stats.health = clampi(heal_val + stats.health, 0, stats.max_health)
	%Damage_numbers.text = str(heal_val)
	%Damage_numbers.modulate = Color("39ad00ff")
	display_damage()

func attack(target_cell : Vector2i):
	turn_to_target(target_cell)
	await self.direction_changed
	if char_animation.has_animation("Attack_1_windup"):
		char_animation.play("Attack_1_windup")
		await char_animation.animation_finished
		attack_trail.turn_on()
		char_animation.play("Attack_1")
		await char_animation.animation_finished
		attack_trail.turn_off()
		if char_animation.has_animation("Attack_1_back"):
			char_animation.play("Attack_1_back")
	attack_finished.emit()

func skill(target_cell : Vector2i, skill_is_jump := false):
	await get_tree().process_frame
	turn_to_target(target_cell)
	await self.direction_changed
	if skill_is_jump:
		animate_skill_jump(target_cell)
	else:
		attack_finished.emit()

func animate_skill_jump(target_cell):
	if char_animation.has_animation("Spell_jump_up"):
		char_animation.play("Spell_jump_up")
		await char_animation.animation_finished
		
		var ap : AnimationPlayer = $AnimationPlayer
		var anim := ap.get_animation("Spell_jump_up")
		anim.track_set_key_value(0, 0, position)
		anim.track_set_key_value(0, 1, position + Vector3(0, 10, 0))
		ap.play("Spell_jump_up")
		await ap.animation_finished
		
		char_animation.play("Spell_jump_attack_windup")
		await char_animation.animation_finished
		attack_trail.turn_on()
		char_animation.play("Spell_jump_attack")
		await char_animation.animation_finished
		attack_trail.turn_off()
		
		send_projectile(target_cell)
		
		anim = ap.get_animation("Spell_jump_back")
		anim.track_set_key_value(0, 0, position)
		anim.track_set_key_value(0, 1, position - Vector3(0, 10, 0))
		ap.play("Spell_jump_back")
		char_animation.play("Spell_jump_attack_back")
		await char_animation.animation_finished
		char_animation.play("Spell_jump_back")
		await char_animation.animation_finished
		char_animation.play("Spell_jump_back_land")
	else:
		attack_finished.emit()

func send_projectile(target_cell):
	var projectile : Node3D = %Flying_slash.duplicate()
	BattleHandler.map_gen.add_child(projectile)
	projectile.global_position = %Flying_slash.global_position
	projectile.global_rotation = %Flying_slash.global_rotation
	projectile.show()
	var tween := create_tween()
	var pos : Vector3
	if BattleHandler.map_gen.map_cells.has(target_cell):
		pos = BattleHandler.map_gen.map_cells[target_cell].position
	else:
		pos = Vector3(target_cell.x * 2.0, 0, target_cell.y * 2.0)
	tween.tween_property(projectile, "position", pos, 1.0)
	tween.tween_callback(remove_projectile.bind(projectile))

func remove_projectile(projectile : Node3D):
	projectile.queue_free()
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
		await get_tree().process_frame
		turn_finished()
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

func undo_move(map_cells : Dictionary[Vector2i, Map_cell]):
	position = map_cells[previous_map_pos].position
	can_move = true
	map_pos = previous_map_pos
	can_undo_move = false

func load_state(save_char_data : Save_char_data):
	can_move = save_char_data.can_move
	can_attack = save_char_data.can_attack
	is_defending = save_char_data.is_defending
	has_order = save_char_data.has_order
	can_undo_move = save_char_data.can_undo_move
	map_pos = save_char_data.map_pos
	previous_map_pos = save_char_data.previous_map_pos
	stats = save_char_data.stats
	is_enemy = save_char_data.is_enemy
	turn(save_char_data.current_direction, true)

func magic_cost(value : int):
	stats.magic -= value











#
