extends GutTest

var _core: Cpu6502

func before_each():
	pass

func after_each():
	pass

#func test_orphans():
#	_core = Cpu6502.new()
#	_core.free()
#	assert_no_new_orphans()

func test_IMP():
	assert_eq(true, true, "First one!")
