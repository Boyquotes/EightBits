extends GutTest

var _memory: Memory

func before_each():
	pass

func after_each():
	pass

#func test_orphans():
#	_memory = Memory.new()
#	_memory.free()
#	assert_no_new_orphans()

func test_set():
	_memory = Memory.new()
	var error: bool = false
	for v in range(0, 256, 32):
		for i in range(0, 65536):
			_memory.write(i, v)
			if _memory.read(i) != v:
				error = true
	assert_eq(error, false)
	_memory.free()
