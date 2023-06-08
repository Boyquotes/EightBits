extends Control

# the core we are attached to
var core

# UI
@onready var pc_value: Label = Crutils.find_node("PCValue")
@onready var acc_value: Label = Crutils.find_node("AccValue")
@onready var x_value: Label = Crutils.find_node("XValue")
@onready var y_value: Label = Crutils.find_node("YValue")
@onready var sp_value: Label = Crutils.find_node("SPValue")
@onready var status_value: Label = Crutils.find_node("StatusValue")

# Called when the node enters the scene tree for the first time.
func _ready():
	core = Crutils.find_node("cpu6502")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pc_value.text = Crutils.int_to_hex4string(core.reg_pc)
	acc_value.text = Crutils.int_to_hex2string(core.reg_acc)
	x_value.text = Crutils.int_to_hex2string(core.reg_x)
	y_value.text = Crutils.int_to_hex2string(core.reg_y)
	sp_value.text = Crutils.int_to_hex2string(core.reg_sp)
	status_value.text = core.get_status_register_string()

func _on_step_button_pressed():
	core.tick_instruction()

func _on_run_button_pressed():
	core.running = !core.running
