extends CanvasLayer

class_name Transition_screen

@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal finished

func on():
	show()
	%Panel.show()
	%Panel2.hide()
	animation_player.play("turn_on")

func off():
	show()
	%Panel.hide()
	%Panel2.show()
	animation_player.play("turn_off")

@warning_ignore("unused_parameter")
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	finished.emit()





#
