@tool
extends EditorPlugin

var io_assembler_dialog

func _enter_tree():
	io_assembler_dialog = preload("res://addons/assembler/assembler_dock.tscn").instantiate()
	io_assembler_dialog.editor_interface = get_editor_interface()
	add_control_to_dock(DOCK_SLOT_LEFT_UL, io_assembler_dialog)

func _exit_tree():
	remove_control_from_docks(io_assembler_dialog)
