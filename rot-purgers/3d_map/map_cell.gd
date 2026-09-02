@tool
extends Node3D

class_name Map_cell

@export var temp_terr_data : Terrain_data
@export var start : bool = false:
	set(value):
		make_floor_mesh()

@export var cell_position : Vector2i

var neighbors_sides : Array[Vector2i] = [
	Vector2i.UP,
	Vector2i.RIGHT,
	Vector2i.DOWN,
	Vector2i.LEFT,
]
@onready var neib_to_side : Dictionary[Vector2i, Array] = {
	Vector2i.UP : top_border,
	Vector2i.RIGHT : right_border,
	Vector2i.DOWN : bottom_border,
	Vector2i.LEFT : left_border
}
var neib_reverse : Dictionary[Vector2i, bool] = {
	Vector2i.UP : true,
	Vector2i.RIGHT : true,
	Vector2i.DOWN : false,
	Vector2i.LEFT : false
}
var neib_to_wall : Dictionary[Vector2i, MeshInstance3D] = {}

signal camera_entered

var walls : Dictionary[Map_generator.directions, MeshInstance3D] = {}
var wall_is_limited : Dictionary[MeshInstance3D, bool] = {}

func make_meshes(terrain_map : Dictionary[Vector2i, Terrain_data], cell : Vector2i):
	cell_position = cell
	make_floor_mesh()
	for neib in neighbors_sides:
		var depth : float
		if terrain_map[cell].depth == 0:
			depth = terrain_map[cell].height
			depth *= 0.1
		
		if terrain_map.has(cell + neib):
			if terrain_map[cell + neib].depth == 0:
				var depth_n : float = terrain_map[cell].height - terrain_map[cell + neib].height
				if depth_n > 0:
					depth_n *= 0.1
					depth = depth_n
				#else:
					#continue
		
		if terrain_map[cell].depth != 0:
			depth = terrain_map[cell].depth * 0.1
		
		var wall := make_wall(neib, depth)
		if terrain_map[cell].depth != 0:
			wall_is_limited[wall] = true
		else:
			wall_is_limited[wall] = false
	load_materials(terrain_map[cell])
	change_terrain_check()

func change_terrain_check():
	if position.y >= 0:
		if ObjectLink.map_gen.terrain_map[cell_position].depth == 0:
			%Terrain_collision.shape.size.y = position.y
		else:
			%Terrain_collision.shape.size.y = ObjectLink.map_gen.terrain_map[cell_position].depth * 0.1
		%Terrain_check.position.y = -%Terrain_collision.shape.size.y / 2

func load_materials(terrain_data : Terrain_data):
	%Floor.set_surface_override_material(0, terrain_data.floor_material)
	for wall in walls.values():
		wall.set_surface_override_material(0, terrain_data.wall_material)

func make_wall(neib : Vector2i, depth : float) -> MeshInstance3D:
	var wall := MeshInstance3D.new()
	add_child(wall)
	walls[BattleHandler.map_gen.vector_to_dir[neib]] = wall
	wall.mesh = make_wall_mesh(neib_to_side[neib], depth, neib_reverse[neib])
	neib_to_wall[neib] = wall
	return wall

func make_wall_mesh(_wall_border : Array[int], depth : float, reverse := true) -> ArrayMesh:
	var array_mesh := ArrayMesh.new()
	var surface_array := []
	surface_array.resize(Mesh.ARRAY_MAX)
	surface_array[Mesh.ARRAY_VERTEX] = PackedVector3Array()
	surface_array[Mesh.ARRAY_INDEX] = PackedInt32Array()
	surface_array[Mesh.ARRAY_TEX_UV] = PackedVector2Array()
	
	vertex_array = surface_array[Mesh.ARRAY_VERTEX]
	index_array = surface_array[Mesh.ARRAY_INDEX]
	texture_uv_array = surface_array[Mesh.ARRAY_TEX_UV]
	
	var resolution := 4
	i = 0
	
	var floor_vertex = get_mesh_vertex(%Floor.mesh)
	
	for z in resolution*2 +1:
		for x in _wall_border.size():
			var vertex : Vector3 = floor_vertex[_wall_border[_wall_border.size() - x - 1]]
			if !reverse:
				vertex = floor_vertex[_wall_border[x]]
			vertex.y -= depth * (resolution * 2 - z) / (resolution * 2)
			vertex_array.append(vertex)
			texture_uv_array.append(Vector2(1.0 - (x as float) / (_wall_border.size() - 1),
			 1.0 - (z as float) / (resolution*2)))
			if x == _wall_border.size() - 1 or z == resolution*2:
				i += 1
				continue
			var index : Array[int] = []
			index.append_array([i, i+1, i+_wall_border.size()])
			index.append_array([i+1, i+1+_wall_border.size(), i+_wall_border.size()])
			index_array.append_array(index)
			i += 1
	
	add_noise(_wall_border.size(), resolution)
	
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	var mdt := MeshDataTool.new()
	mdt.create_from_surface(array_mesh, 0)
	array_mesh = normalize(mdt, array_mesh)
	return array_mesh

func add_noise(length : int,resolution : int):
	i = 0
	var noise := FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 1
	
	var v1 := Vector2(vertex_array[0].x, vertex_array[0].z)
	var v2 := Vector2(vertex_array[1].x, vertex_array[1].z)
	var normal : Vector2 = (v1 - v2).orthogonal().normalized()
	
	for z in resolution*2 +1:
		for x in length:
			if z == 0 or z == resolution*2 or x == 0 or x == length-1:
				i += 1
				continue
			var vertex : Vector3 = vertex_array[i]
			var d : Vector2 = noise.get_noise_3dv(vertex) * normal * 0.1
			vertex.x += d.x
			vertex.z += d.y
			vertex_array[i] = vertex
			i += 1

func get_mesh_vertex(mesh : ArrayMesh) -> PackedVector3Array:
	var surface_array := []
	surface_array.resize(Mesh.ARRAY_MAX)
	surface_array = mesh.surface_get_arrays(0)
	return surface_array[Mesh.ARRAY_VERTEX]

var right_border : Array[int] = []
var bottom_border : Array[int] = []
var top_border : Array[int] = []
var left_border : Array[int] = []
var temp_array : Array[int] = [] 

var vertex_array : PackedVector3Array
var index_array : PackedInt32Array
var texture_uv_array : PackedVector2Array

var i := 0

@warning_ignore("unused_parameter")
func make_floor_mesh():
	var array_mesh := ArrayMesh.new()
	var surface_array := []
	surface_array.resize(Mesh.ARRAY_MAX)
	surface_array[Mesh.ARRAY_VERTEX] = PackedVector3Array()
	surface_array[Mesh.ARRAY_INDEX] = PackedInt32Array()
	surface_array[Mesh.ARRAY_TEX_UV] = PackedVector2Array()
	
	vertex_array = surface_array[Mesh.ARRAY_VERTEX]
	index_array = surface_array[Mesh.ARRAY_INDEX]
	texture_uv_array = surface_array[Mesh.ARRAY_TEX_UV]
	
	var size = 2.0
	var half_size = size/2
	var resolution := 4
	
	i = 0
	for z in resolution*2+1:
		for x in resolution*2+1:
			var vertex := Vector3(half_size - x*half_size / resolution, 0,
			half_size - z*half_size / resolution)
			vertex_array.append(vertex)
			if z == 0:
				bottom_border.append(i)
			if x == 0:
				right_border.append(i)
			if x == resolution*2:
				left_border.append(i)
			if z == resolution*2:
				top_border.append(i)
			texture_uv_array.append(Vector2(1.0 - (x as float) / (resolution*2),
			 1.0 - (z as float) / (resolution*2)))
			if z == resolution*2 or x == resolution*2:
				i += 1
				continue
			var index : Array[int] = []
			index.append_array([i, i+1, i+1+resolution*2])
			index.append_array([i+1, i+2+resolution*2, i+1+resolution*2])
			index_array.append_array(index)
			i += 1
	
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	var mdt := MeshDataTool.new()
	mdt.create_from_surface(array_mesh, 0)
	array_mesh = normalize(mdt, array_mesh)
	
	array_mesh = change_floor_elevation(array_mesh, FastNoiseLite.new(), 0.2, Vector3.ZERO)
	
	%Floor.mesh = array_mesh

func normalize(mdt : MeshDataTool, mesh : ArrayMesh) -> ArrayMesh:
	for ii in range(mdt.get_face_count()):
		# Get the index in the vertex array.
		var a = mdt.get_face_vertex(ii, 0)
		var b = mdt.get_face_vertex(ii, 1)
		var c = mdt.get_face_vertex(ii, 2)
		# Get the vertex position using the vertex index.
		var ap = mdt.get_vertex(a)
		var bp = mdt.get_vertex(b)
		var cp = mdt.get_vertex(c)
		# Calculate the normal of the face.
		var n = (bp - cp).cross(ap - bp).normalized()
		# Add this face normal to the current vertex normals.
		# This will not result in perfect normals, but it will be close.
		mdt.set_vertex_normal(a, n + mdt.get_vertex_normal(a))
		mdt.set_vertex_normal(b, n + mdt.get_vertex_normal(b))
		mdt.set_vertex_normal(c, n + mdt.get_vertex_normal(c))
	
	for ii in range(mdt.get_vertex_count()):
		var v := mdt.get_vertex_normal(ii).normalized()
		mdt.set_vertex_normal(ii, v)
	
	mesh.clear_surfaces()
	mdt.commit_to_surface(mesh)
	return mesh

var floor_elevation : Dictionary[int, float] = {}
func change_floor_elevation(mesh : ArrayMesh, noise : FastNoiseLite, 
height : float, node_position : Vector3,
curve : Curve = null, zone_center : Vector3 = Vector3.ZERO, zone_length := 0.0) -> ArrayMesh:
	var mdt := MeshDataTool.new()
	mdt.create_from_surface(mesh, 0)
	
	var noise_s := FastNoiseLite.new()
	noise_s.frequency = 1
	noise_s.seed = randi()
	
	for ii in mdt.get_vertex_count():
		var vertex : Vector3 = mdt.get_vertex(ii)
		var y : float = noise.get_noise_2d(node_position.x + vertex.x, 
		node_position.z + vertex.z) * height
		
		if zone_center != Vector3.ZERO:
			var dist : float = (node_position + vertex - zone_center).length()
			if dist < zone_length:
				var modulation : float = curve.sample(dist / zone_length)
				y *= modulation
		
		if !right_border.has(ii) and !left_border.has(ii) and !top_border.has(ii) and !bottom_border.has(ii):
			y += noise_s.get_noise_2d(vertex.x, vertex.z) * 0.15
		vertex.y += y
		floor_elevation[ii] = y
		mdt.set_vertex(ii, vertex)
	
	mesh = normalize(mdt, mesh)
	return mesh

var move_tween : Tween
var tween_progress := 0.0:
	set(value):
		tween_progress = value
		if check_walls():
			update_walls()
			change_terrain_check()
var target_height : int
func update_height(value : int, zone : Node3D):
	target_height = value
	if move_tween != null:
		if move_tween.is_running():
			move_tween.kill()
	move_tween = create_tween()
	move_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	move_tween.set_parallel()
	tween_progress = 0.0
	move_tween.tween_property(self, "position", position + Vector3(0, value * 0.1 - position.y, 0), 1.0)
	move_tween.tween_property(zone, "position", position + Vector3(0, value * 0.1 - position.y, 0), 1.0)
	move_tween.tween_property(self, "tween_progress", 1.0, 1.0)
	if BattleHandler.map_gen.char_positions.has(cell_position):
		var char_node : Character_node = BattleHandler.map_gen.char_positions[cell_position]
		move_tween.tween_property(char_node, "position", char_node.position + Vector3(0, value * 0.1 - position.y, 0), 1.0)

func update_walls():
	for dir in walls:
		var wall : MeshInstance3D = walls[dir]
		if !wall_is_limited[wall]:
			wall.mesh = update_wall_mesh(wall.mesh, dir)

func update_wall_mesh(mesh : ArrayMesh, dir : Map_generator.directions):
	var mdt := MeshDataTool.new()
	mdt.create_from_surface(mesh, 0)
	
	var depth : float = position.y
	var neib : Vector2i = BattleHandler.map_gen.dir_to_vector[dir]
	if BattleHandler.map_gen.map_cells.has(cell_position + neib):
		if BattleHandler.map_gen.terrain_map[cell_position + neib].depth == 0:
			depth -= BattleHandler.map_gen.map_cells[cell_position + neib].position.y
		else:
			depth = position.y

	@warning_ignore("narrowing_conversion")
	var res : int = sqrt(mdt.get_vertex_count())
	
	for ii in mdt.get_vertex_count():
		var vertex : Vector3 = mdt.get_vertex(ii)
		@warning_ignore("integer_division")
		var z : int = ii / res
		vertex.y = - depth * (res - z - 1) / (res - 1)
		mdt.set_vertex(ii, vertex)
	
	mesh.clear_surfaces()
	mdt.commit_to_surface(mesh)
	return mesh

func check_walls() -> bool:
	for neib in neighbors_sides:
		if BattleHandler.map_gen.map_cells.has(cell_position + neib):
			var map_cell : Map_cell = BattleHandler.map_gen.map_cells[cell_position + neib]
			map_cell.check_walls_neib(-neib)
	for neib in neighbors_sides:
		check_walls_self(neib)
	
	return true

func check_walls_self(neib : Vector2i) -> bool:
	var cell := neib + cell_position
	if !BattleHandler.map_gen.map_cells.has(cell):
		return true
	var height_diff : float = position.y
	var depth : int = BattleHandler.map_gen.terrain_mod_data[cell_position].depth
	if BattleHandler.map_gen.terrain_map[cell].depth != 0:
		height_diff = position.y
	else:
		height_diff -= BattleHandler.map_gen.map_cells[cell].position.y
	var dir : Map_generator.directions = BattleHandler.map_gen.vector_to_dir[neib]
	if walls.has(dir) and height_diff <= 0.0:
		walls[dir].queue_free()
		walls.erase(dir)
		return false
	if height_diff > 0.0 and !walls.has(dir):
		var wall : MeshInstance3D
		if depth == 0:
			wall = make_wall(neib, height_diff * 10)
		else:
			wall = make_wall(neib, depth * 0.1)
		if depth != 0:
			wall_is_limited[wall] = true
		else:
			wall_is_limited[wall] = false
		wall.set_surface_override_material(0, 
		BattleHandler.map_gen.terrain_map[cell_position].wall_material)
		return false
	return true

func check_walls_neib(neib : Vector2i):
	if BattleHandler.map_gen.terrain_map[cell_position].depth != 0:
		return
	var cell := neib + cell_position
	var height_diff : float = position.y
	height_diff -= BattleHandler.map_gen.map_cells[cell].position.y
	var dir : Map_generator.directions = BattleHandler.map_gen.vector_to_dir[neib]
	if BattleHandler.map_gen.terrain_map[cell].depth != 0:
			return
	if walls.has(dir) and height_diff <= 0.0:
		walls[dir].queue_free()
		walls.erase(dir)
		return
	if height_diff > 0.0 and !walls.has(dir):
		var depth : int = BattleHandler.map_gen.terrain_map[cell_position].depth
		@warning_ignore("confusable_local_declaration")
		var wall : MeshInstance3D
		if depth == 0:
			wall = make_wall(neib, height_diff * 10)
		else:
			wall = make_wall(neib, depth * 0.1)
		if depth != 0:
			wall_is_limited[wall] = true
		else:
			wall_is_limited[wall] = false
		wall.set_surface_override_material(0, 
		BattleHandler.map_gen.terrain_map[cell_position].wall_material)
		return
	if walls.has(dir):
		var wall : MeshInstance3D = walls[dir]
		update_wall_mesh(wall.mesh, dir)

func _on_mouse_detector_body_entered(body: Node3D) -> void:
	if body.get_parent() is Camera_controller:
		camera_entered.emit()








#
