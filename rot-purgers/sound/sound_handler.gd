extends Node

class_name Sound_handler

@onready var damage_player: AudioStreamPlayer = %Damage
@onready var music_player: AudioStreamPlayer = %Music
@onready var sfx_player: AudioStreamPlayer = %Sfx


func play_damage():
	damage_player.play()

func play_music(music : AudioStream):
	if music_player.stream == music:
		return
	music_player.stream = music
	music_player.play()

func play_sfx(sfx : AudioStream):
	sfx_player.stream = sfx
	sfx_player.play()

@export var menu_music : AudioStream
@export var tutor_music : AudioStream

func play_menu():
	%Music.stop()
	%Music.stream = menu_music
	%Music.play()

func play_tutor():
	%Music.stop()
	%Music.stream = tutor_music
	%Music.play()







#
