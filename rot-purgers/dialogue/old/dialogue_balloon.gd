extends CanvasLayer

class_name Dialogue_balloon

var text_data : Text_data

signal line_read
signal text_read
var dialogue_in_progress := false
var can_read_next := true
var line_tween : Tween

var current_line : String
var pause_index : int

func _ready() -> void:
	hide()

func show_text(_text_data : Text_data, index : int = 0):
	show()
	dialogue_in_progress = true
	text_data = _text_data
	for i in range(index, text_data.lines.size()):
		var line : Line_data = text_data.lines[i]
		if line.text == "*":
			pause_index = i
			dialogue_in_progress = false
			hide()
			text_read.emit()
			return
		can_read_next = false
		%Char_name.text = line.char_name
		%Char_text.text = ""
		line_tween = create_tween()
		var dur : float = line.text.length() * 0.02
		current_line = line.text
		line_tween.tween_property(%Char_text, "text", line.text, dur)
		line_tween.tween_callback(next_line)
		await self.line_read
	dialogue_in_progress = false
	hide()
	text_read.emit()

func next_line():
	can_read_next = true

func _input(event: InputEvent) -> void:
	if !dialogue_in_progress:
		return
	if event.is_action_pressed("dialogue_next"):
		if can_read_next:
			line_read.emit()
		else:
			finish_line()

func finish_line():
	line_tween.kill()
	can_read_next = true
	%Char_text.text = current_line







#
