extends Character_node

class_name tutorial_char

var gained_rot := false
var rot_reverse := false

func change_rot(value : int):
	super(value)
	if value > 0:
		gained_rot = true
	elif value < 0:
		rot_reverse = true
