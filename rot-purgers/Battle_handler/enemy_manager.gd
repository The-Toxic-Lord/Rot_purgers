extends Node

class_name Enemy_manager

signal enemies_turn_ended

func start_enemy_turn():
	await get_tree().process_frame
	end_enemy_turn()

func end_enemy_turn():
	enemies_turn_ended.emit()












#
