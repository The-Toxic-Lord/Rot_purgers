extends CanvasLayer

class_name Map_UI

@onready var map_generator : Map_generator = get_parent()
signal map_spawn_character

func _ready() -> void:
	populate_spawn_list()



func open_spawn_menu():
	%Character_select_menu.show()
	await get_tree().process_frame
	%Character_list.get_child(0).grab_focus()

var button_to_char : Dictionary[BaseButton, Character] = {}
var spawn_list : Dictionary[Character, BaseButton]

func populate_spawn_list():
	for ch in GlobalData.ally_team:
		var bt : Button = load("uid://dk2af1blnp7lq").instantiate().duplicate()
		%Character_list.add_child(bt)
		button_to_char[bt] = ch
		spawn_list[ch] = bt
		bt.text = ch.name
		bt.pressed.connect(spawn_character.bind(ch))
		bt.focus_entered.connect(show_focus_char_stats.bind(ch))
		bt.mouse_entered.connect(func() -> void:
			bt.grab_focus()
		)
	%Character_list.move_child(%Close_spawn, %Character_list.get_children().size() - 1)

func show_focus_char_stats(ch : Character):
	$Focused_char_stats.show()
	$Focused_char_stats.update_stats(ch)

func close_spawn_menu():
	$Focused_char_stats.hide()
	%Character_select_menu.hide()
	map_generator.freze_selector = false

func spawn_character(ch : Character):
	map_spawn_character.emit(ch)
	button_to_char.erase(spawn_list[ch])
	spawn_list[ch].queue_free()
	spawn_list.erase(ch)
	close_spawn_menu()






#
