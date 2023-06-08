extends Node

var memory: PackedByteArray

func _ready() -> void:
	memory.resize(65536)

func _process(_delta: float) -> void:
	pass

func read(address: int) -> int:
	return memory[address & 0xffff]

func write(address: int, value: int) -> void:
	memory[address & 0xffff] = value & 0xff	
