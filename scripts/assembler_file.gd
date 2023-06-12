@tool
class_name AssemblerFile
extends Node

var _file_root: String
var _input_filename: String
var _output_filename: String
var _list_filename: String
var _symbol_filename: String
var _build_output: PackedStringArray

func _init():
	pass

func update_files():
	pass

func is_input_file_present() -> bool:
	return FileAccess.file_exists(_file_root + _input_filename)

func is_output_file_present() -> bool:
	return FileAccess.file_exists(_file_root + _output_filename)

func is_list_file_present() -> bool:
	return FileAccess.file_exists(_file_root + _list_filename)
	
func is_symbol_file_present() -> bool:
	return FileAccess.file_exists(_file_root + _symbol_filename)

func set_file_root(root: String):
	_file_root = root
	
func set_input_filename(filename: String):
	_input_filename = filename
	var dot_pos = filename.find(".asm")
	var prefix = filename.substr(0, dot_pos)
	_output_filename = prefix + ".bin"
	_list_filename = prefix + ".lst"
	_symbol_filename = prefix + ".sym"

func get_input_filename() -> String:
	return _input_filename

func build() -> bool:
	print("Building " + _input_filename)
	var dot_pos = _input_filename.find(".asm")
	var prefix = _input_filename.substr(0, dot_pos)
	var output = []
	OS.execute("./dasm/dasm", ["asm/" + prefix + ".asm", "-oasm/"+prefix+".bin", "-lasm/"+prefix+".lst", "-sasm/"+prefix+".sym", "-v1"], output, true, true)
	_build_output = output[0].split("\n")
	if output[0].ends_with("Complete. (0)\n"):
		print("build successful")
		return true
	else:
		print("build failed")
		return false
