@tool
extends Panel


func _ready():
	RenderingServer.canvas_item_set_clip(get_canvas_item(), true)

func _process(delta):
	pass
