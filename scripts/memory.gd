class_name Memory
extends Node

var _memory: PackedByteArray

func _init() -> void:
	_memory.resize(65536)

func _deinit():
	pass

func read(address: int) -> int:
	return _memory[address & 0xffff]

func write(address: int, value: int) -> void:
	_memory[address & 0xffff] = value & 0xff	
