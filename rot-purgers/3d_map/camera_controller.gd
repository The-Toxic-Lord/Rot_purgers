extends Node3D

class_name Camera_controller

@onready var map_generator : Map_generator = get_parent()

@onready var rotation_x : Node3D = %Camera_rotation_x
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

func _ready() -> void:
	move_target = position
	#rotation_target = rotation_degrees.y
	zoom_target = camera.position.z

func _input(event: InputEvent) -> void:
	if BattleHandler.state != Battle_handler.states.PLAYER:
		return
	if event.is_action_pressed("zoom_in"):
		zoom_target -= zoom_speed
		zoom_target = clamp(zoom_target, zoom_min, zoom_max)
	elif event.is_action_pressed("zoom_out"):
		zoom_target += zoom_speed
		zoom_target = clamp(zoom_target, zoom_min, zoom_max)

func _unhandled_input(event: InputEvent) -> void:
	if BattleHandler.state == Battle_handler.states.PLAYER:
		if event is InputEventMouseMotion and Input.is_action_pressed("rotate"):
			var quat : Quaternion = Quaternion(Vector3.DOWN, event.relative.x * rotation_speed * 0.25)
			quaternion = quat * quaternion

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	handle_movement()
	handle_height()
	handle_rotation()
	camera.position.z = lerp(camera.position.z, zoom_target, 0.1)

func handle_movement():
	if follow_target != null:
		move_target = follow_target.position
	elif BattleHandler.state == Battle_handler.states.PLAYER:
		var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		var move_dir := (transform.basis * Vector3(input_vector.x , 0, input_vector.y)).normalized()
		
		move_target += move_speed * move_dir
		var flat_v := Vector2(move_target.x, move_target.z)
		if !move_boundary.has_point(flat_v):
			move_target.x = clampf(move_target.x, move_boundary.position.x, 
				move_boundary.position.x + move_boundary.size.x)
			move_target.z = clampf(move_target.z, move_boundary.position.y,
			move_boundary.position.y + move_boundary.size.y)
	position = lerp(position, move_target, 0.2)

func handle_height():
	move_target.y =	map_generator.get_position_height(position)

func handle_rotation():
	if BattleHandler.state == Battle_handler.states.PLAYER:
		var rotation_dir := Input.get_axis("rotate_left", "rotate_right")
		var quat : Quaternion = Quaternion(Vector3.UP, rotation_dir * rotation_speed)
		quaternion = quat * quaternion






#
