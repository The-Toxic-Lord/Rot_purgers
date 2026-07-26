extends MarginContainer

class_name Mini_char_stats

func update_stats(ch : Character_stats):
	%Char_name.text = ch.name
	%Move_speed.text = "Mv : " + str(ch.move_speed)
	%Jump_height.text = "Jm : " + str(ch.jump_height)
	%Health.text = str(int(ch.health))
	%Magic.text = str(int(ch.magic))
	
	%Health_bar.max_value = ch.max_health
	%Health_bar.value = ch.health
	
	%Magic_bar.max_value = ch.max_magic
	%Magic_bar.value = ch.magic
	
	if ch.sprite != null:
		%Sprite.texture = ch.sprite
