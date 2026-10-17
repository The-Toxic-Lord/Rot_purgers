extends MarginContainer

class_name Focused_char_stats

@onready var st_to_lb : Dictionary[Character_stats.stats, Label] = {
	Character_stats.stats.strength : %Strength,
	Character_stats.stats.defence : %Defence,
	Character_stats.stats.accuracy : %Accuracy,
	Character_stats.stats.speed : %Speed,
	Character_stats.stats.jump_height : %Jump_height,
	Character_stats.stats.move_speed : %Move_speed
}

func update_stats(ch : Character_stats):
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
	if ch.sprite != null:
		%Sprite.texture = ch.sprite
	
	for stat in st_to_lb.keys():
		if !ch.boosts.has(stat):
			continue
		if ch.boosts[stat] != 0:
			st_to_lb[stat].text += "+" + str(ch.boosts[stat])







#
