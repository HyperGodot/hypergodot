extends "res://src/HyperRequest/HyperRequest.gd"

signal content(content)

func getContent(path):
	request(path)
	pass

func _on_GetContent_request_completed(result, response_code, headers, body):
	var content = body.get_string_from_utf8()
	
	if response_code != 200: return printerr(content)
	emit_signal("content", content)
	pass # Replace with function body.
