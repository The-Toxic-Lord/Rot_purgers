extends Node3D

class_name Cutscene

@export var text_data : DialogueResource
@export var player : AnimationPlayer
@export var chars : Dictionary[String, Node3D] = {}

func start_cutscene():
	await get_tree().process_frame
	DialogueBalloon.start(text_data, "cutscene")
	if player != null:
		ObjectLink.cutscene_player = player
	if !chars.is_empty():
		ObjectLink.cutscene_chars = chars
	await DialogueManager.dialogue_ended
	var main : Main_node = get_parent()
	main.load_map()
