extends Character_node

signal projectile_hit

func attack(target_cell : Vector2i):
	turn_to_target(target_cell)
	await self.direction_changed
	var ranged_checK := true
	for neib in neighbors_sides:
		var cell := neib + map_pos
		if target_cell == cell:
			await melee_attack()
			ranged_checK = false
			break
	if ranged_checK:
		ranged_attack(target_cell)
		await projectile_hit
	else:
		pass
	attack_finished.emit()

func melee_attack():
	pass

func ranged_attack(target_cell : Vector2i):
	await spawn_projectile(target_cell)

func spawn_projectile(target_cell : Vector2i):
	var projectile : Projectile_3d = load("uid://dpujirha88ifa").instantiate()
	add_child(projectile)
	var spawner : Node3D = %Projectile_spawner
	projectile.global_position = spawner.global_position
	var target : Vector3
	if ObjectLink.map_gen.map_cells.has(target_cell):
		target = Vector3(target_cell.x * 2.0, 
		ObjectLink.map_gen.map_cells[target_cell].position.y + 1.5, target_cell.y * 2.0)
	else:
		target = Vector3(target_cell.x * 2.0, 0, target_cell.y * 2.0)
	projectile.start(target)
	
	var tween := create_tween()
	tween.tween_property(projectile, "global_position", target, 0.5)
	tween.tween_callback(projectile.set_physics_process.bind(false))
	tween.tween_callback(projectile_hit.emit)
	tween.tween_callback(projectile.queue_free)










#
