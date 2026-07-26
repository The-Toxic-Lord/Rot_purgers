extends Node

class_name Sound_handler



func play_damage():
	%Damage.play()

func play_music(music : AudioStream):
	if %Music.stream == music:
		return
	%Music.stream = music
	%Music.play()

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
