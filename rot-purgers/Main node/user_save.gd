extends Resource

class_name User_save

@export_storage var achievements : Dictionary[String, bool] = {
	"NORMAL_end_a" : false,
	"NORMAL_end_b" : false,
	"HARD_end_a" : false,
	"EASY_end_a" : false,
	"EASY_secret" : false,
	"HARD_all_alive" : false
}

func add_achievement(diff : Global_data.Difficulty, line : String):
	var cue : String = Global_data.Difficulty.keys()[diff] + "_" + line
	await check_cue(cue)
	if diff == Global_data.Difficulty.HARD and GlobalData.dead_chars.is_empty():
		await check_cue("HARD_all_alive")
	GlobalData.clear_data()
	save_self()

func check_cue(cue : String):
	if achievements.has(cue):
		if !achievements[cue]:
			ObjectLink.main.main_menu.animate_achievement(ObjectLink.main.main_menu.achievement_texts[cue])
		achievements[cue] = true

func save_self():
	ResourceSaver.save(self, "user://saves/user.res")
