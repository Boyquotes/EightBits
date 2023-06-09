class_name BootRoot
extends Node

@onready var cpu: Cpu6502 = Crutils.find_node("cpu6502")

func _ready() -> void:
	cpu.load_rom("res://roms/combat.bin", 0xf000)
	cpu.load_rom("res://roms/combat.bin", 0xf800)
	cpu.set_pc_from_reset_vector()
