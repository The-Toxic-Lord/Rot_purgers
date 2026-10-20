extends CanvasLayer

class_name Transition_screen

@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal finished

func on():
	show()
	%Panel.show()
	%Panel2.hide()
	animation_player.play("turn_on")
	%Label.text = ""
	%ProgressBar.value = 0
	await animation_player.animation_finished
	show_progress()

func off():
	hide_progress()
	show()
	%Panel.hide()
	%Panel2.show()
	animation_player.play("turn_off")

@warning_ignore("unused_parameter")
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	finished.emit()

func set_lb(_str : String):
	%Label.text = _str

func update_progress(value : float):
	%ProgressBar.value = value * 100

func reset_progress_bar():
	%ProgressBar.value = 0.0

func show_progress():
	%Label.show()
	%ProgressBar.show()

func hide_progress():
	%Label.hide()
	%ProgressBar.hide()







#
