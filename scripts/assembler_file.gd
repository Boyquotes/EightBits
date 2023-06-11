@tool
class_name AssemblerFile
extends Node

@export_file("*.asm") var input_filename: String
@export_file("*.bin") var export_filename: String
@export_file("*.lst") var list_file: String
@export_file("*.sym") var symbol_file: String

var confirmed_present: bool

func _init():
	confirmed_present = true
