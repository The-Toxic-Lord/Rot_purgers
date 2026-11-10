@tool extends Node3D

class_name Cutscene

@export var text_data : DialogueResource
@export var player : AnimationPlayer
@export_tool_button("Find chars") var find_chars = chars_find
@export var chars : Array[Cutscene_char] = []
@export var objects : Array[Cutscene_object] = []
@export var next_map_path : String
@export var cameras : Array[Camera3D]
@export var music : AudioStream

signal load_finished

func chars_find():
	chars = []
	cameras = []
	objects = []
	for child in get_children():
		if child is Cutscene_char:
			chars.append(child)
		elif child is Camera3D:
			cameras.append(child)
	for child in get_children(true):
		if child is Cutscene_object:
			objects.append(child)

func _ready() -> void:
	if !Engine.is_editor_hint():
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
	for i in cameras.size():
		cameras[i].position = game_save.cameras_position[i]
		cameras[i].quaternion = game_save.cameras_rotation[i]
	for i in chars.size():
		chars[i].position = game_save.chars_position[i]
		chars[i].quaternion = game_save.chars_rotation[i]
		chars[i].visible = game_save.chars_visibility[i]
		chars[i].load_anim(game_save.chars_animation[i])
	for i in objects.size():
		objects[i].position = game_save.objects_position[i]
		objects[i].quaternion = game_save.objects_rotation[i]
		objects[i].visible = game_save.objects_visibility[i]
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
