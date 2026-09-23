extends Skill_animation_3d

@onready var valley_01 : Array[Node3D] = [
	%MProjectileJavelinVFX_01, %MProjectileJavelinVFX_02, %MProjectileJavelinVFX_03
]
@onready var valley_02 : Array[Node3D] = [
	%MProjectileJavelinVFX_04, %MProjectileJavelinVFX_05, %MProjectileJavelinVFX_06
]
@onready var valley_03 : Array[Node3D] = [
	%MProjectileJavelinVFX_07, %MProjectileJavelinVFX_08, %MProjectileJavelinVFX_09
]
@onready var valley_04 : Array[Node3D] = [
	%MProjectileJavelinVFX_10, %MProjectileJavelinVFX_11, %MProjectileJavelinVFX_12
]
@onready var valley_05 : Array[Node3D] = [
	%MProjectileJavelinVFX_13, %MProjectileJavelinVFX_14, %MProjectileJavelinVFX_15
]
@export var animation_time : float = 1.0

@export var sfx : AudioStream

func start(target : Vector3) -> void:
	SoundHandler.play_sfx(sfx)
	position.y = 5.0
	await get_tree().process_frame
	var volleys : Array = [valley_01, valley_02, valley_03, valley_04, valley_05]
	var cell_t : Array[Vector2i] = [Vector2i(int(target.x / 2.0), int(target.z / 2.0))]
	for neib in GlobalData.neighbors_sides:
		var cell : Vector2i = neib + cell_t[0]
		cell_t.append(cell)
	var tween := create_tween()
	tween.set_parallel(true)
	for i in cell_t.size():
		var targ_pos : Vector3
		if ObjectLink.map_gen.map_cells.has(cell_t[i]):
			targ_pos = ObjectLink.map_gen.map_cells[cell_t[i]].position
		elif ObjectLink.map_gen.void_cells.has(cell_t[i]):
			targ_pos = ObjectLink.map_gen.void_cells[cell_t[i]].position
		else:
			targ_pos = Vector3(cell_t[i].x * 2.0, 0.0, cell_t[i].y * 2.0)
		for proj : Node3D in volleys[i]:
			var proj_targ : Vector3 = targ_pos + Vector3(randf_range(-1, 1), 0.0 , randf_range(-1, 1))
			proj.look_at(proj_targ, Vector3.UP, true)
			tween.tween_property(proj, "global_position", proj_targ, animation_time)
	await get_tree().create_timer(animation_time).timeout
	#SoundHandler.stop_sfx()
	animation_finished.emit()










#
