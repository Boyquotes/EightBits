extends GutTest

var _file: AssemblerFile
var _temp_root: String = "res://temp/"
var _temp_asm_filename: String = "temp.asm"
var _temp_bin_filename: String = "temp.bin"
var _temp_lst_filename: String = "temp.lst"
var _temp_sym_filename: String = "temp.sym"

func before_all():
	pass

func _flush_files():
	# Clean out temp files
	if FileAccess.file_exists(_temp_root + _temp_asm_filename):
		DirAccess.remove_absolute(_temp_root + _temp_asm_filename)
	if FileAccess.file_exists(_temp_root + _temp_bin_filename):
		DirAccess.remove_absolute(_temp_root + _temp_bin_filename)
	if FileAccess.file_exists(_temp_root + _temp_lst_filename):
		DirAccess.remove_absolute(_temp_root + _temp_lst_filename)
	if FileAccess.file_exists(_temp_root + _temp_sym_filename):
		DirAccess.remove_absolute(_temp_root + _temp_sym_filename)

func before_each():
	_file = AssemblerFile.new()
	_file.set_file_root(_temp_root)
	_flush_files()

func after_each():
	pass

func after_all():
	_flush_files()
	
func test_creation():
	assert_eq(_file != null, true, "Creation")

func test_input_not_present():
	_file.set_input_filename(_temp_asm_filename)
	assert_eq(_file.is_input_file_present(), false, "Input file not present")

func test_input_present():
	var new_file = FileAccess.open(_temp_root + _temp_asm_filename, FileAccess.WRITE)
	new_file.close()
	_file.set_input_filename(_temp_asm_filename)
	assert_eq(_file.is_input_file_present(), true, "Input file present")

func test_autodetect_output_present():
	var new_asm_file = FileAccess.open(_temp_root + _temp_asm_filename, FileAccess.WRITE)
	new_asm_file.close()
	var new_bin_file = FileAccess.open(_temp_root + _temp_bin_filename, FileAccess.WRITE)
	new_bin_file.close()
	_file.set_input_filename(_temp_asm_filename)
	assert_eq(_file.is_output_file_present(), true, "Output file auto-detect present")

func test_autodetect_output_not_present():
	var new_asm_file = FileAccess.open(_temp_root + _temp_asm_filename, FileAccess.WRITE)
	new_asm_file.close()
	_file.set_input_filename(_temp_asm_filename)
	assert_eq(_file.is_output_file_present(), false, "Output file auto-detect not present")

func test_autodetect_list_present():
	var new_asm_file = FileAccess.open(_temp_root + _temp_asm_filename, FileAccess.WRITE)
	new_asm_file.close()
	var new_lst_file = FileAccess.open(_temp_root + _temp_lst_filename, FileAccess.WRITE)
	new_lst_file.close()
	_file.set_input_filename(_temp_asm_filename)
	assert_eq(_file.is_list_file_present(), true, "List file auto-detect present")

func test_autodetect_list_not_present():
	var new_asm_file = FileAccess.open(_temp_root + _temp_asm_filename, FileAccess.WRITE)
	new_asm_file.close()
	_file.set_input_filename(_temp_asm_filename)
	assert_eq(_file.is_list_file_present(), false, "List file auto-detect not present")

func test_autodetect_symbol_present():
	var new_asm_file = FileAccess.open(_temp_root + _temp_asm_filename, FileAccess.WRITE)
	new_asm_file.close()
	var new_sym_file = FileAccess.open(_temp_root + _temp_sym_filename, FileAccess.WRITE)
	new_sym_file.close()
	_file.set_input_filename(_temp_asm_filename)
	assert_eq(_file.is_symbol_file_present(), true, "Symbol file auto-detect present")

func test_autodetect_symbol_not_present():
	var new_asm_file = FileAccess.open(_temp_root + _temp_asm_filename, FileAccess.WRITE)
	new_asm_file.close()
	_file.set_input_filename(_temp_asm_filename)
	assert_eq(_file.is_symbol_file_present(), false, "Symbol file auto-detect not present")
