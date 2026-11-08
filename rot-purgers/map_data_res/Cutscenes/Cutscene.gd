extends Node3D

class_name Cutscene

@export var text_data : DialogueResource
@export var player : AnimationPlayer
@export var chars : Dictionary[String, Cutscene_char] = {}
@export var next_map_path : String
@export var cameras : Array[Camera3D]
@export var music : AudioStream

signal load_finished

func _ready() -> void:
	ObjectLink.cutscene = self

func start_cutscene(_extra_data = null):
	await get_tree().process_frame
	bind_objects()
	load_finished.emit()
	SoundHandler.stop_music()
	if music != null:
		SoundHandler.play_music(music)
	if player != null:
		if _extra_data != null and _extra_data is String and _extra_data != "":
			player.play(_extra_data)
		else:
			player.play("start")

func bind_objects():
	if !chars.is_empty():
		ObjectLink.cutscene_chars = chars
	if !cameras.is_empty():
		ObjectLink.cutscene_cameras = cameras
	if player != null:
		ObjectLink.cutscene_player = player

func load_save(game_save : Game_save):
	bind_objects()
	DialogueBalloon.dialogue_resource = text_data
	await get_tree().process_frame
	DialogueBalloon.load_str(game_save.line_id)
	DialogueBalloon.show()

func start_dialogue(cue : String):
	DialogueBalloon.start(text_data, cue)

func next_scene(map_path := next_map_path, scene_cue := ""):
	var main : Main_node = get_parent()
	main.load_scene_path(map_path, scene_cue)

func make_camera_current(id : int):
	for i in cameras.size():
		cameras[i].clear_current()
	await get_tree().process_frame
	cameras[id].make_current()

func play_sfx(sfx : AudioStream, sfx_player_id := 0):
	SoundHandler.play_sfx(sfx, sfx_player_id)

func play_animation(anim_name : String):
	player.play(anim_name)






#
