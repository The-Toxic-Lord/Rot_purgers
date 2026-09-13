extends Character_node

class_name Observer

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var beam_vfx: Beam_vfx = %BaseBeamVFX
@onready var eye_forward: MeshInstance3D = %Eye_forward

@onready var observer_model: Observer_model = %Observer_model

signal eye_rotation_finished

func attack(target_cell : Vector2i):
	turn_to_target(target_cell)
	await self.direction_changed
	
	var target_pos : Vector3 = ObjectLink.map_gen.map_cells[target_cell].position + Vector3(0, 1.5, 0)
	observer_model.stop_eye(eye_forward)
	var q := eye_forward.quaternion
	eye_forward.look_at(target_pos)
	var t := eye_forward.quaternion
	eye_forward.quaternion = q
	
	var tween := create_tween()
	tween.tween_property(eye_forward, "quaternion", t, 1.0)
	tween.tween_callback(eye_rotation_finished.emit)
	
	await eye_rotation_finished
	
	beam_vfx.beam_length = (target_pos - eye_forward.global_position).length()
	beam_vfx.show()
	
	attack_finished.emit()
	
	await get_tree().create_timer(0.5).timeout
	beam_vfx.hide()
















#
