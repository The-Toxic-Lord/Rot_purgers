extends Node3D

func _ready() -> void:
	%anim_1.play("Idle")
	%anim_2.play("Idle")

func start_cutscene(text_data : Text_data):
	DialogueBalloon.show_text(text_data)
	await DialogueBalloon.text_read
	var main : Main_node = get_parent()
	main.load_map()
