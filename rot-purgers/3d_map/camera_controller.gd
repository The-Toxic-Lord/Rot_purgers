extends Node3D

class_name Camera_controller

@onready var map_generator : Map_generator = get_parent()

@onready var zoom_pivot : Node3D = %Camera_zoom_pivot
@onready var camera : Camera3D = %Camera3D

@export var move_speed := 0.3
var move_target : Vector3
var follow_target : Node3D = null
var move_boundary : Rect2

@export var rotation_speed := 0.02
#var rotation_target : float

@export var zoom_speed := 1.0
var zoom_target : float
var zoom_min := -10.0
var zoom_max := 10.0

var moving := false
var controller_input : Array[String] = [
	"move_up_one", "move_right_one", "move_down_one", "move_left_one"
	]
var controller_dir : Array[Vector2i] = [
	Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT
]
var camera_cell : Vector2i
var move_one_dir := Vector2i.ZERO
var cell_boundary : Rect2i

var zoom := 0

func _ready() -> void:
	move_target = position
	#rotation_target = rotation_degrees.y
	zoom_target = camera.position.z

func _input(event: InputEvent) -> void:
	if DialogueBalloon.is_working:
		return
	if BattleHandler.state != Battle_handler.states.PLAYER:
		return
	if event.is_action_pressed("zoom_in"):
		if event is InputEventJoypadMotion:
			if event.axis_value != 1.0:
				zoom = 0
			else:
				zoom = 1
		else:
			zoom_target -= zoom_speed
			zoom_target = clamp(zoom_target, zoom_min, zoom_max)
	elif event.is_action_pressed("zoom_out"):
		if event is InputEventJoypadMotion:
			if event.axis_value != 1.0:
				zoom = 0
			else:
				zoom = -1
		else:
			zoom_target += zoom_speed
			zoom_target = clamp(zoom_target, zoom_min, zoom_max)
	if map_generator.state in [Map_generator.states.MENU]:
		return
	for key in controller_input:
		if event.is_action(key):
			if event.is_pressed():
				move_one_dir = get_dir(key)
				if cell_boundary.has_point(camera_cell + move_one_dir):
					camera_cell += move_one_dir
					moving = true
					if map_generator.map_cells.has(camera_cell):
						move_target = map_generator.map_cells[camera_cell].position
					else:
						move_target = Vector3(2.0 * camera_cell.x, 0.0, 2.0 * camera_cell.y)
						map_generator.set_selector(camera_cell)
			elif event.is_released():
				move_one_dir = Vector2i.ZERO

func get_dir(key : String) -> Vector2i:
	var id : int = controller_input.find(key)
	var angle : float = rad_to_deg(rotation.y)
	if angle > -50 and angle < 50:
		return controller_dir[id]
	if angle > 50 and angle < 140:
		id += -1
		if id < 0:
			id = 3
		return controller_dir[id]
	elif angle < -50 and angle > -140:
		id += 1
		if id > 3:
			id = 0
		return controller_dir[id]
	else:
		id += 2
		if id > 3:
			id -= 4
		return controller_dir[id]

func _unhandled_input(event: InputEvent) -> void:
	if DialogueBalloon.is_working:
		return
	if BattleHandler.state == Battle_handler.states.PLAYER:
		if event is InputEventMouseMotion and Input.is_action_pressed("rotate"):
			var quat : Quaternion = Quaternion(Vector3.DOWN, event.relative.x * rotation_speed * 0.25)
			quaternion = quat * quaternion

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	handle_movement()
	handle_height()
	handle_rotation()
	handle_zoom(delta)
	camera.position.z = lerp(camera.position.z, zoom_target, 0.1)

func handle_movement():
	if follow_target != null:
		move_target = follow_target.position
	elif DialogueBalloon.is_working:
		return
	elif BattleHandler.state == Battle_handler.states.PLAYER:
		if map_generator.state in [Map_generator.states.MENU]:
			return
		if move_one_dir == Vector2i.ZERO:
			var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
			var move_dir := (transform.basis * Vector3(input_vector.x , 0, input_vector.y)).normalized()
			
			move_target += move_speed * move_dir
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
	position = lerp(position, move_target, 0.2)
	if (position - move_target).length() < 0.1:
		moving = false
	else:
		moving = true

func handle_height():
	move_target.y =	map_generator.get_position_height(position)

func handle_rotation():
	if DialogueBalloon.is_working:
		return
	if BattleHandler.state == Battle_handler.states.PLAYER:
		if map_generator.state in [Map_generator.states.MENU]:
			return
		var rotation_dir := Input.get_axis("rotate_left", "rotate_right")
		var quat : Quaternion = Quaternion(Vector3.UP, rotation_dir * rotation_speed)
		quaternion = quat * quaternion

func handle_zoom(delta : float):
	match zoom:
		0:
			return
		1:
			zoom_target -= zoom_speed * delta * 10
		-1:
			zoom_target += zoom_speed * delta * 10
	zoom_target = clamp(zoom_target, zoom_min, zoom_max)



#
