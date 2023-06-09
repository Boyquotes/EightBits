@tool
extends EditorImportPlugin

enum Presets { NORMAL }

func _get_importer_name():
	return "asm6502"

func _get_visible_name():
	return "6502 Asm"

func _get_recognized_extensions():
	return ["asm"]

func _get_save_extension():
	return "bin"

func _get_resource_type():
	return "Resource"

func _get_priority():
	return 1.0

func _get_preset_count():
	return Presets.size()

func _get_preset_name(preset_index):
	return "NORMAL"

func _get_import_options(path, preset_index):
	return []

func _get_import_order():
	return 0

func _import(source_file, save_path, options, platform_variants, gen_files):
	var file: FileAccess = FileAccess.open(source_file, FileAccess.READ)
	if file == null:
		print("file is null")
		return FAILED
	var output = Resource.new()
# Fill the Mesh with data read in "file", left as an exercise to the reader.
	var filename = save_path + "." + _get_save_extension()
	var ret = ResourceSaver.save(output, filename, ResourceSaver.FLAG_COMPRESS | ResourceSaver.FLAG_BUNDLE_RESOURCES)
	return ret
	
