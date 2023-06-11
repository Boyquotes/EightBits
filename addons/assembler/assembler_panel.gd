@tool
extends Panel

var editor_interface

var assembler_files = {}
var source_folder: String
var destination_folder: String
@onready var files_vbox: VBoxContainer = Crutils.find_node("Files VBoxContainer")

func _ready():
	source_folder = "res://asm"
	destination_folder = "res://roms"
	RenderingServer.canvas_item_set_clip(get_canvas_item(), true)

func assembler_file_exists(name: String) -> bool:
	var found: bool = false
	return found

func set_all_assembler_files_as_non_confirmed():
	for file in assembler_files:
		assembler_files[file].confirmed_present = false

func remove_all_assembler_files_ui_items():
	var children = files_vbox.get_children()
	for child in children:
		child.queue_free()

func _on_refresh_button_pressed():
	print("Refresh pressed")
	set_all_assembler_files_as_non_confirmed()
	remove_all_assembler_files_ui_items()
	var dir = DirAccess.open(source_folder)
	if dir:
		dir.list_dir_begin()
		var file: String = dir.get_next()		
		while file != "":
			if file.ends_with(".asm"):
				if file in assembler_files:
					assembler_files[file].confirmed_present = true
				else:
					assembler_files[file] = AssemblerFile.new()
					
				# add label for file
				var new_label = Label.new()
				new_label.text = file
				files_vbox.add_child(new_label)
				
			file = dir.get_next()
		dir.list_dir_end()

func _on_build_button_pressed():
	print("Build pressed")

func _on_rebuild_all_button_pressed():
	print("Rebuild All pressed")
