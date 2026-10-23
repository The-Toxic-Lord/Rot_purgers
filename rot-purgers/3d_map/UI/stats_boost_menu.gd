extends MarginContainer

class_name Stat_boost_menu

@onready var labels : Array[Label] = [
	%Health_lb, %Strength_lb2, %Defence_lb3, 
	%Accuracy_lb4, %Speed_lb5, %Jump_lb6, %Move_lb7
]

@onready var sliders : Array[HSlider] = [
	%Health_slider, %Strength_slider2, %Defence_slider3, 
	%Accuracy_slider4, %Speed_slider5, %Jump_height_slider, %"Move_speed _slider"
]

var stats : Array[Character_stats.stats] = [
	Character_stats.stats.max_health,
	Character_stats.stats.strength,
	Character_stats.stats.defence,
	Character_stats.stats.accuracy,
	Character_stats.stats.speed,
	Character_stats.stats.jump_height,
	Character_stats.stats.move_speed
]

var char_stats : Character_stats
func load_char(char_node : Character_node):
	char_stats = char_node.stats
	var stat_value : int = 0
	magic_cost = 0
	for id in stats.size():
		var stat := stats[id]
		if char_stats.boosts.has(stat):
			stat_value = char_stats.boosts[stat]
		else:
			char_stats.boosts[stat] = 0
			stat_value = 0
		set_label(id, stat_value)
		var slider : HSlider = sliders[id]
		slider.value = stat_value
		magic_cost += int(slider.value / slider.step)
	set_magic_cost_label()

func set_label(id : int, value : int):
	var label : Label = labels[id]
	var ii : int = label.text.find(":")
	label.text = label.text.substr(0, ii + 2)
	label.text += str(value)

func set_magic_cost_label():
	%Cost.text = "Magic cost per turn : " +\
	 str(snappedi(magic_cost * GlobalData.map_magic_cost_adjustment, 1))

var magic_cost := 0
func _on_slider_drag_ended(value_changed: bool, source: Slider) -> void:
	if !value_changed:
		return
	
	var id : int = sliders.find(source)
	var value : float = source.value
	var value_change : float = source.value - char_stats.boosts[stats[id]]
	
	char_stats.boosts[stats[id]] = int(value)
	
	set_label(id, int(value))
	
	magic_cost += int(value_change / source.step)
	set_magic_cost_label()

func _on_slider_value_changed(value: float, source: Range) -> void:
	var id : int = sliders.find(source)
	var value_change : float = source.value - char_stats.boosts[stats[id]]
	
	char_stats.boosts[stats[id]] = int(value)
	
	set_label(id, int(value))
	
	magic_cost += int(value_change / source.step)
	set_magic_cost_label()

signal confirm
func _on_confirm_bt_pressed() -> void:
	hide()
	confirm.emit()
	ObjectLink.focused_char_stats.update_stats(char_stats)
	char_stats.boost_magic_cost = snappedi(magic_cost * GlobalData.map_magic_cost_adjustment, 1)







#
