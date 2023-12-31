@tool
extends Panel

var editor_interface

var assembler_files = {}
var source_folder: String
#var files_vbox: VBoxContainer

@onready var files_vbox: VBoxContainer = Crutils.find_node("Files VBoxContainer")

func _init_ui():
	if files_vbox == null:
		files_vbox = Crutils.find_node("Files VBoxContainer")

func _ready():
	source_folder = "res://asm"
	RenderingServer.canvas_item_set_clip(get_canvas_item(), true)

func assembler_file_exists(name: String) -> bool:
	var found: bool = false
	return found

func remove_deleted_asm_files():
	_init_ui()
	var to_delete = []
	for assembler_file in assembler_files:
		if not assembler_files[assembler_file].is_input_file_present():
			print("Missing file " + assembler_file)
			to_delete.append(assembler_file)
	for del in to_delete:
		assembler_files.remove(del)

func remove_all_assembler_files_ui_items():
	var children = files_vbox.get_children()
	for child in children:
		child.queue_free()

func does_assembler_file_need_building(file: AssemblerFile) -> bool:
	var answer: bool = false
	return answer

# non-recursive for now
func get_all_asm_filenames(root: String) -> Array[String]:
	var ret: Array[String]
	var dir = DirAccess.open(root)
	if dir:
		dir.list_dir_begin()
		var file: String = dir.get_next()		
		while file != "":
			if file.ends_with(".asm"):
				ret.append(file)
			file = dir.get_next()
		dir.list_dir_end()
	return ret

func _refresh():
	remove_deleted_asm_files()
	remove_all_assembler_files_ui_items()

	var asm_filenames = get_all_asm_filenames("res://asm")
	for asm_filename in asm_filenames:
		
		# add asm_file to known assembler files
		if asm_filename not in assembler_files:
			var new_assembler_file = AssemblerFile.new()
			new_assembler_file.set_input_filename(asm_filename)
			new_assembler_file.set_file_root("res://asm/")
			assembler_files[asm_filename] = new_assembler_file
			
		# add label for file - this needs to be a proper complex element at some point
		var new_label = Label.new()
		if assembler_files[asm_filename].get_built():
			new_label.text = asm_filename + " - BUILT OK"
		else:
			new_label.text = asm_filename + " - NOT BUILT"
		files_vbox.add_child(new_label)

func _on_refresh_button_pressed():
	print("Refresh pressed")
	_refresh()

func _on_build_button_pressed():
	print("Build pressed")
	for assembler_file in assembler_files:
		assembler_files[assembler_file].build()
	_refresh()

func _on_rebuild_all_button_pressed():
	print("Rebuild All pressed")
