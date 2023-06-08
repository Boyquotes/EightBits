extends GutTest

func before_all():
	gut.p("Runs once before all tests")

func before_each():
	gut.p("Runs before each test.")

func after_each():
	gut.p("Runs after each test.")

func after_all():
	gut.p("Runs once after all tests")
	
func test_first():
	gut.p("test_first")
	assert_eq(true, true, "First one!")

func test_second():
	gut.p("test_second")
	assert_eq(true, true, "Second one!")

func test_third():
	gut.p("test_third")
	assert_eq(true, true, "Third one!")
