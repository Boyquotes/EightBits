extends GutTest

var _core: Cpu6502

func before_each():
	_core = Cpu6502.new()

func after_each():
	_core.free()

func test_IMP():
	assert_eq(true, true, "First one!")
