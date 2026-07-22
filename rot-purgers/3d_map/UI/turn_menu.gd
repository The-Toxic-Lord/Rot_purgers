extends MarginContainer

class_name Turn_menu

@onready var button_to_signal : Dictionary[BaseButton, Signal] = {
	%Execute : execute, 
	%End_turn : end_turn, 
	%Settings : settings, 
	%Exit : exit
}

signal execute
signal end_turn
signal settings
signal exit


func _on_turn_button_pressed(source: BaseButton) -> void:
	button_to_signal[source].emit()

func focus():
	%Execute.grab_focus()
	if BattleHandler.attack_array.is_empty():
		%Execute.disabled = true
	else:
		%Execute.disabled = false
