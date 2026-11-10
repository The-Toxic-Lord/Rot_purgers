extends Character_node

@onready var animation_tree: AnimationTree = $AnimationTree

func move_normal(pos : Vector3, time := 0.5):
	var tween_blend := create_tween()
	tween_blend.tween_property(animation_tree, "parameters/walk_blend/blend_amount", 1.0, 0.25)
	
	var tween := create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(self, "position", pos, time)
	await tween.finished
	
	tween_blend = create_tween()
	tween_blend.tween_property(animation_tree, "parameters/walk_blend/blend_amount", 0.0, 0.25)




#
