extends Node3D

class_name Cutscene_char

@export var start_anim : String
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var animation_tree: AnimationTree


func _ready() -> void:
	if start_anim != "":
		animation_player.play(start_anim)
	if find_child("AnimationTree") != null:
		animation_tree = find_child("AnimationTree")

func play_anim(anim_name : String):
	animation_player.play(anim_name)
	last_anim_name = anim_name

func load_anim(anim_name : String):
	animation_player.play(anim_name)
	animation_player.seek(999, true, true)
	last_anim_name = anim_name

func play_anim_sequence(anim_names : Array[String]):
	for anim in anim_names:
		animation_player.play(anim)
		await animation_player.animation_finished

var last_anim_name : String
func get_anim_name() -> String:
	if animation_player.current_animation != "":
		return animation_player.current_animation
	else:
		return last_anim_name

func stop_animation():
	animation_player.stop()

func start_tree():
	animation_tree.active = true

func stop_tree():
	animation_tree.active = false









#
