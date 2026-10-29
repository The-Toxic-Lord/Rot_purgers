extends Node3D

class_name Cutscene

@export var text_data : DialogueResource
@export var player : AnimationPlayer
@export var chars : Dictionary[String, Cutscene_char] = {}
@export var next_map_path : String
@export var cameras : Array[Camera3D]

signal load_finished

func _ready() -> void:
	ObjectLink.cutscene = self

func start_cutscene():
	await get_tree().process_frame
	if !chars.is_empty():
		ObjectLink.cutscene_chars = chars
	if !cameras.is_empty():
		ObjectLink.cutscene_cameras = cameras
	load_finished.emit()
	if player != null:
		ObjectLink.cutscene_player = player
		player.play("start")

func load_save(game_save : Game_save):
	DialogueBalloon.start(text_data, "cutscene")
	await get_tree().process_frame
	DialogueBalloon.load_str(game_save.line_id)

func start_dialogue(cue : String):
	DialogueBalloon.start(text_data, cue)

func next_scene():
	var main : Main_node = get_parent()
	main.load_scene_path(next_map_path)

func make_camera_current(id : int):
	for i in cameras.size():
		cameras[i].clear_current()
	await get_tree().process_frame
	cameras[id].make_current()






#
