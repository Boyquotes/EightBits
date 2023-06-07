extends Node

func search_node(node: Node, name: String) -> Node:
	if node.name == name:
		return node
	for child in node.get_children():
		var result = search_node(child, name)
		if result:
			return result
	return null
	
func find_node(name: String) -> Node:
	var node = search_node(get_tree().get_root(), name)
	if node:
		print("Node found:", node)
	else:
		print("Node not found")
	return node

func int_to_hex2string(value: int) -> String:
	var format_string = "0x%02x"
	return format_string % [value & 0xff]

func int_to_hex4string(value: int) -> String:
	var format_string = "0x%04x"
	return format_string % [value & 0xffff]
	
