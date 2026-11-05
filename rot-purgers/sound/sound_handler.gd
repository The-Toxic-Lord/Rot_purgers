extends Node

class_name Sound_handler

@onready var damage_player: AudioStreamPlayer = %Damage
@onready var music_player: AudioStreamPlayer = %Music
@onready var sfx_player: AudioStreamPlayer = %Sfx
@onready var sfx_players : Array[AudioStreamPlayer] = [
	%Sfx, %Sfx_m12, %Sfx_m24
]

func play_damage():
	damage_player.play()

func play_music(music : AudioStream):
	if music_player.stream == music:
		return
	music_player.stream = music
	music_player.play()

func stop_music():
	%Music.stop()

func play_sfx(sfx : AudioStream, sfx_player_id := 0):
	sfx_players[sfx_player_id].stream = sfx
	sfx_players[sfx_player_id].play()

func stop_sfx(sfx_player_id := 0):
	sfx_players[sfx_player_id].stop()

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

@export var error_sfx : AudioStream
func play_error():
	play_sfx(error_sfx)










#
