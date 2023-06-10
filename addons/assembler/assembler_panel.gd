@tool
extends Panel

var editor_interface

var assembler_files = []
var source_folder: String
var destination_folder: String

func _ready():
	source_folder = "res://asm"
	destination_folder = "res://roms"
	RenderingServer.canvas_item_set_clip(get_canvas_item(), true)

func _on_refresh_button_pressed():
	print("Refresh pressed")
	var dir = DirAccess.open(source_folder)
	if dir:
		dir.list_dir_begin()
		var file = dir.get_next()
		
		while file != "":
			print(file)
			file = dir.get_next
		dir.list_dir_end()
		
