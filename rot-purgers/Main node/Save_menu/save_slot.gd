extends MarginContainer

class_name Save_slot

signal delete
signal load
signal overwrite

func load_data(save : Game_save):
	%Screenshot.texture = save.screenshot
	%Save_name.text = save.save_name
	%load_bt.pressed.connect(load.emit.bind(save))
	%delete_bt.pressed.connect(delete.emit.bind(save.save_name))
	%Overwrite_bt.pressed.connect(overwrite.emit.bind(save.save_name))
	%Load_bt_big.pressed.connect(load.emit.bind(save))
