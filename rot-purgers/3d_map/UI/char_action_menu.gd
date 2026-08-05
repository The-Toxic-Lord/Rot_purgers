extends MarginContainer

class_name Char_action_menu

signal move
signal attack
signal spell
signal defend
signal exit
signal rearange

@onready var button_to_signal : Dictionary[BaseButton, Signal] = {
	%Move : move,
	%Attack : attack,
	%Spell : spell,
	%Defend : defend,
	%Exit : exit,
	%Stats : rearange
}

func _on_action_button_pressed(source: BaseButton) -> void:
	button_to_signal[source].emit()

func update_disabled(ch_node : Character_node):
	if BattleHandler.enemies.has(ch_node):
		%Move.disabled = true
		%Attack.disabled = true
		%Spell.disabled = true
		%Defend.disabled = true
		return
	if ch_node.has_order:
		%Move.disabled = true
		%Attack.disabled = true
		%Spell.disabled = true
		%Defend.disabled = true
		return
	if ch_node.can_move:
		%Move.disabled = false
	else:
		%Move.disabled = true
	if ch_node.can_attack:
		%Attack.disabled = false
		%Spell.disabled = false
		%Defend.disabled = false
	else:
		%Attack.disabled = true
		%Spell.disabled = true
		%Defend.disabled = true
	if ch_node.car_rearange:
		%Stats.disabled = false
	else:
		%Stats.disabled = true

func focus(id : int = 0):
	var bt_array : Array[BaseButton] = button_to_signal.keys()
	bt_array[id].grab_focus()







#
