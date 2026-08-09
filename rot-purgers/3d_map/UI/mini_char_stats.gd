extends MarginContainer

class_name Mini_char_stats

func update_stats(ch : Character_stats):
	%Char_name.text = ch.name
	%Move_speed.text = "Mv : " + str(ch.move_speed)
	%Jump_height.text = "Jm : " + str(ch.jump_height)
	%Magic.text = str(int(ch.magic))
	
	%Health_bar.max_value = ch.max_health
	%Health_bar.value = ch.health
	
	%Magic_bar.max_value = ch.max_magic
	%Magic_bar.value = ch.magic
	
	if ch.sprite != null:
		%Sprite.texture = ch.sprite

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
