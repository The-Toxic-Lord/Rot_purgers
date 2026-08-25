extends Node3D



func start_cutscene(text_data : Text_data):
	await get_tree().process_frame
	
	CutsceneBalloon.start(load("uid://bhj75sl17uhsm"), "test")
	await DialogueManager.dialogue_ended
	#DialogueManager._start_balloon(CutsceneBalloon, load("uid://bhj75sl17uhsm"), "test", [])
	
	#DialogueBalloon.show_text(text_data)
	#await DialogueBalloon.text_read
	var main : Main_node = get_parent()
	main.load_map()
