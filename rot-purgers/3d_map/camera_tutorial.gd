extends Camera_controller

class_name Camera_tutorial

var movement_bools : Array[bool] = [
	false,false,false
]

var tutor_vector : Vector3 = Vector3.ZERO
var tutor_angle : float = 0.0
var prev_angle : float = 0.0
var tutor_zoom : float = 0.0
var prev_zoom : float = 0.0

func handle_movement():
	if follow_target != null:
		move_target = follow_target.position
	elif DialogueBalloon.is_working:
		pass
	elif BattleHandler.state == Battle_handler.states.PLAYER:
		if map_generator.terrain_mod_menu_active:
			return
		if map_generator.state in [Map_generator.states.MENU]:
			return
		if move_one_dir == Vector2i.ZERO:
			var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
			var move_dir := (transform.basis * Vector3(input_vector.x , 0, input_vector.y)).normalized()
			
			if !movement_bools[0]:
				tutor_vector += abs(move_dir)
				if tutor_vector.length() >= 50:
					movement_bools[0] = true
			
			if !Input.is_action_pressed("fast_move"):
				move_target += move_speed * move_dir
			else:
				move_target += move_speed * move_dir * 2
			var flat_v := Vector2(move_target.x, move_target.z)
			if !move_boundary.has_point(flat_v):
				move_target.x = clampf(move_target.x, move_boundary.position.x, 
					move_boundary.position.x + move_boundary.size.x)
				move_target.z = clampf(move_target.z, move_boundary.position.y,
				move_boundary.position.y + move_boundary.size.y)
		elif !moving:
			if cell_boundary.has_point(camera_cell + move_one_dir):
				camera_cell += move_one_dir
				moving = true
				if map_generator.map_cells.has(camera_cell):
					move_target = map_generator.map_cells[camera_cell].position
				else:
					move_target = Vector3(2.0 * camera_cell.x, 0.0, 2.0 * camera_cell.y)
					map_generator.set_selector(camera_cell)
	if !Input.is_action_pressed("fast_move"):
		position = lerp(position, move_target, 0.2)
	else:
		position = lerp(position, move_target, 0.5)
	if (position - move_target).length() < 0.1:
		moving = false
	else:
		moving = true


@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	super(delta)
	if movement_bools[0] and !movement_bools[1]:
		tutor_angle += abs(rotation.y - prev_angle)
		prev_angle = rotation.y
		if  tutor_angle >= PI:
			movement_bools[1] = true
	if movement_bools[1]:
		tutor_zoom += abs(zoom_target - prev_zoom)
		prev_zoom = zoom_target
		if tutor_zoom >= 15.0:
			movement_bools[2] = true
			movement_bools[1] = false











#
