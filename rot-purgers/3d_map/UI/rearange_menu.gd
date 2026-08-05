extends MarginContainer

class_name Rearange_menu

@onready var labels : Array[Label] = [
	%Health_lb, %Strength_lb2, %Defence_lb3, %Accuracy_lb4, %Speed_lb5
]

@onready var sliders : Array[HSlider] = [
	%Health_slider, %Strength_slider2, %Defence_slider3, %Accuracy_slider4, %Speed_slider5
]

var stats : Array[Character_stats.stats] = [
	Character_stats.stats.max_health,
	Character_stats.stats.strength,
	Character_stats.stats.defence,
	Character_stats.stats.accuracy,
	Character_stats.stats.speed
]

signal confirm

var char_stats : Character_stats
func load_char(char_node : Character_node):
	var char_stats_base : Character_stats = char_node.base_stats
	char_stats = char_node.stats
	%Readjust_points.text = "Readjust points : " + str(char_stats.readjust_points)
	for i in stats.size():
		var slider : HSlider = sliders[i]
		slider.max_value = char_stats_base.get_stat(stats[i]) * 1.5
		slider.min_value = char_stats_base.get_stat(stats[i]) * 0.5
		if i == 0:
			slider.step = 5.0
		slider.value = char_stats.get_stat(stats[i])
		var label : Label = labels[i]
		var ii : int = label.text.find(":")
		label.text = label.text.substr(0, ii + 2)
		label.text += str(char_stats.get_stat(stats[i]))

func _on_slider_drag_ended(value_changed: bool, source: Slider) -> void:
	if !value_changed:
		return
	
	var value : float = source.value
	var id : int = sliders.find(source)
	var stat_value : int = char_stats.get_stat(stats[id])
	var readjust_points : int = char_stats.readjust_points
	
	if readjust_points == 0 and stat_value < int(value):
		source.value = stat_value
		return
	
	var diff : int = int(value) - stat_value
	if id == 0:
		@warning_ignore("narrowing_conversion")
		diff *= 0.2
	
	readjust_points -= diff
	stat_value = int(value)
	if readjust_points < 0:
		if id == 0:
			stat_value += readjust_points * 5
		else:
			stat_value += readjust_points
		readjust_points = 0
		source.value = stat_value
	char_stats.set_stat(stats[id], stat_value)
	char_stats.readjust_points = readjust_points
	
	var label : Label = labels[id]
	var ii : int = label.text.find(":")
	label.text = label.text.substr(0, ii + 2)
	label.text += str(int(stat_value))
	%Readjust_points.text = "Readjust points : " + str(readjust_points)

func _on_slider_value_changed(value: float, source: Range) -> void:
	var id : int = sliders.find(source)
	var label : Label = labels[id]
	var ii : int = label.text.find(":")
	label.text = label.text.substr(0, ii + 2)
	label.text += str(int(value))
	
	var readjust_points : int = char_stats.readjust_points
	var stat_value : int = char_stats.get_stat(stats[id])
	var diff : int = int(value) - stat_value
	if id == 0:
		@warning_ignore("narrowing_conversion")
		diff *= 0.2
	readjust_points -= diff
	%Readjust_points.text = "Readjust points : " + str(readjust_points)

func _on_confirm_bt_pressed() -> void:
	hide()
	confirm.emit()






#
