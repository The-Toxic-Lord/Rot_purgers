extends MarginContainer

class_name Focused_char_stats

func update_stats(ch : Character):
	%Char_name.text = ch.name
	%Class.text = ch.char_class
	%Age.text = str(ch.age)
	%Move_speed.text = "Mv : " + str(ch.move_speed)
	%Jump_height.text = "Jm : " + str(ch.jump_height)
	%Health.text = str(int(ch.health)) + " / " + str(int(ch.max_health))
	%Magic.text = str(int(ch.magic)) + " / " + str(int(ch.max_magic))
	%Strength.text = "Str : " + str(ch.strength)
	%Defence.text = "Def : " + str(ch.defence)
	%Mag_str.text = "Magic Str : " + str(ch.magic_strenght)
	%Accuracy.text = "Acc : " + str(ch.accuracy)
	%Speed.text = "Spd : " + str(ch.speed)








#
