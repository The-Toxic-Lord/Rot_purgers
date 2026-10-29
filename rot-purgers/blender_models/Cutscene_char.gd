extends Node3D

class_name Cutscene_char

@export var start_anim : String
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	if start_anim != "":
		animation_player.play(start_anim)

func play_anim(anim_name : String):
	animation_player.play(anim_name)

func play_anim_sequence(anim_names : Array[String]):
	for anim in anim_names:
		animation_player.play(anim)
		await animation_player.animation_finished
