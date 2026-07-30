extends Node3D

func start_cutscene(text_data : Text_data):
	DialogueBalloon.show_text(text_data)
	await DialogueBalloon.text_read
	var main : Main_node = get_parent()
	main.load_map()
