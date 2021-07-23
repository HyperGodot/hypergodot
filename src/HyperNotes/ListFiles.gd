extends "res://src/HyperRequest/HyperRequest.gd"

signal files(files)

func list(path):
	request(path + "?noResolve") 
	pass

func _on_ListFiles_request_completed(result, response_code, headers, body):
	if response_code != 200: return
	
	var content = body.get_string_from_utf8()

	var json = JSON.parse(content)
	
	if json.error != OK: return printerr(json.error_string)

	emit_signal("files", json.result)
	pass # Replace with function body.
