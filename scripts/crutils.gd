@tool
extends Node

func search_node(node: Node, node_name: String) -> Node:
	if node.name == node_name:
		return node
	for child in node.get_children():
		var result = search_node(child, node_name)
		if result:
			return result
	return null
	
func find_node(node_name: String) -> Node:
	var node = search_node(get_tree().get_root(), node_name)
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
	
func hexstring_to_int(value: String) -> int:
	var result = 0
	for i in range(0, value.length()):
		result *= 16
		match value[i]:
			'0':
				result += 0
			'1':
				result += 1
			'2':
				result += 2
			'3':
				result += 3
			'4':
				result += 4
			'5':
				result += 5
			'6':
				result += 6
			'7':
				result += 7
			'8':
				result += 8
			'9':
				result += 9
			'a':
				result += 10
			'b':
				result += 11
			'c':
				result += 12
			'd':
				result += 13
			'e':
				result += 14
			'f':
				result += 15
	return result

func dump_binary_file_to_output(filename: String):
	var file = FileAccess.open(filename, FileAccess.READ)
	if file != null:
		var contents: PackedByteArray = file.get_file_as_bytes(filename)
		for byte in contents:
			print(int_to_hex2string(byte))
	else:
		print("ERROR - dump_binary_file_to_output - cannot open file:" + filename)
		
