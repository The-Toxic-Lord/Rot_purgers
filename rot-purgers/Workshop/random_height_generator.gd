@tool
extends Node

@export_tool_button("generate") var gen_bt = test

@export var terrain_size : Vector2i
@export var min_height : int
@export var max_height : int
@export var step : int


func test():
	var map : Dictionary[Vector2i, int] = {}
	for x in terrain_size.x:
		for y in terrain_size.y:
			var cell : Vector2i = Vector2i(x, y)
			map[cell] = snappedi(randi_range(min_height, max_height), step)
	for y in terrain_size.y:
		var pr_line : Array[int] = []
		for x in terrain_size.x:
			var cell : Vector2i = Vector2i(x, y)
			pr_line.append(map[cell])
		print(pr_line)
