extends MarginContainer

class_name Mini_char_stats

func update_stats(ch : Character_stats):
	%Char_name.text = ch.name
	%Move_speed.text = "Mv : " + str(ch.move_speed)
	if ch.boosts.has(Character_stats.stats.move_speed):
		if ch.boosts[Character_stats.stats.move_speed] != 0:
			%Move_speed.text += "+" + str(ch.boosts[Character_stats.stats.move_speed])
	%Jump_height.text = "Jm : " + str(ch.jump_height)
	if ch.boosts.has(Character_stats.stats.jump_height):
		if ch.boosts[Character_stats.stats.jump_height] != 0:
			%Jump_height.text += "+" + str(ch.boosts[Character_stats.stats.jump_height])
	%Magic.text = str(int(ch.magic))
	
	%Health_bar.max_value = ch.max_health
	%Health_bar.value = ch.health
	%Health.text = str(ch.health)
	
	if ch.penalties.has(Character_stats.stats.max_health) and ch.penalties[Character_stats.stats.max_health] != 0:
		%Rot_bar.show()
		%Rot_bar.max_value = ch.max_health
		%Rot_bar.value = ch.penalties[Character_stats.stats.max_health]
		change_health_corners(0)
	else:
		%Rot_bar.hide()
		change_health_corners(4)

	
	%Magic_bar.max_value = ch.max_magic
	%Magic_bar.value = ch.magic
	%Magic.text = str(ch.magic)
	
	if ch.sprite != null:
		%Sprite.texture = ch.sprite

func change_health_corners(value : int):
	var health_bar: ProgressBar = %Health_bar
	var style_box : StyleBoxFlat = health_bar.get_theme_stylebox("fill")
	style_box.corner_radius_top_right = value
	style_box.corner_radius_bottom_right = value

var damage_tween : Tween

func display_damage(new_value : int):
	if damage_tween != null:
		if damage_tween.is_running():
			damage_tween.kill()
	damage_tween = create_tween()
	damage_tween.tween_property(%Health_bar, "value", new_value, 0.5)

func _on_health_bar_value_changed(value: float) -> void:
	%Health.text = str(int(value))

func play_dead():
	if damage_tween != null:
		if damage_tween.is_running():
			damage_tween.kill()
	damage_tween = create_tween()
	damage_tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.9)
	damage_tween.tween_callback(dead_cleanup)

func dead_cleanup():
	modulate = Color(1.0, 1.0, 1.0, 1.0)
	hide()



#
