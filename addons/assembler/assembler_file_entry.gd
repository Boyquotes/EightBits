@tool
extends Control

@onready var filename_label: Label = $HBoxContainer/FilenameLabel

func _ready():
	pass # Replace with function body.

func set_filename(filename: String):
	filename_label.text = filename
	

func _on_build_button_pressed():
	pass # Replace with function body.


func _on_symbols_button_pressed():
	pass # Replace with function body.


func _on_list_button_pressed():
	pass # Replace with function body.


func _on_dump_button_pressed():
	pass # Replace with function body.
