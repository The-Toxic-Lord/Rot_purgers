extends Resource

class_name User_save

@export_storage var achievements : Array[String] = []

func add_achievement(diff : Global_data.Difficulty, line : String):
	if achievements.has(line):
		return
	achievements.append(line)
