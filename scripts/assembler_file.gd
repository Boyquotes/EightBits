@tool
class_name AssemblerFile
extends Node

var _file_root: String
var _input_filename: String
var _output_filename: String
var _list_filename: String
var _symbol_filename: String
var _build_output: PackedStringArray
var _built: bool
var _symbols = {}

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

func get_built():
	return _built

func _parse_symbols():
	_symbols = {}
	var contents = FileAccess.get_file_as_string(_file_root + _symbol_filename)
	var contents_split = contents.split("\n")
	for line in contents_split:
		if not line.begins_with("---"):
			var this_symbol = ""
			var this_value = 0
			var words = line.split(" ")
			for word in words:
				if word != "":
					if this_symbol == "":
						this_symbol = word
					else:
						this_value = Crutils.hexstring_to_int(word)
						_symbols[this_symbol] = this_value
#	for symbol in _symbols:
#		print(symbol + " = " + str(_symbols[symbol]))

func build() -> bool:
	_built = false
	print("Building " + _input_filename)
	var dot_pos = _input_filename.find(".asm")
	var prefix = _input_filename.substr(0, dot_pos)
	var output = []
	OS.execute("./dasm/dasm", ["asm/" + prefix + ".asm", "-oasm/"+prefix+".bin", "-lasm/"+prefix+".lst", "-sasm/"+prefix+".sym", "-v1"], output, true, true)
	_build_output = output[0].split("\n")
	if output[0].ends_with("Complete. (0)\n"):
		_built = true
		_parse_symbols()
	else:
		_built = false
		print("ERROR")
		for line in _build_output:
			print(line)
	return _built
