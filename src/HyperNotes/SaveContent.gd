extends "res://src/HyperRequest/HyperRequest.gd"

signal saved

func save(path, content):
	print("Saving", path, content)
	self.request(
		path,
		PoolStringArray(["Content-Type: text/plain"]),
		false,
		HTTPClient.METHOD_PUT,
		content
		)
	pass


func _on_SaveContent_request_completed(result, response_code, headers, body):
	if response_code == 200: emit_signal("saved")
	else: printerr(body.get_string_from_utf8())
	pass # Replace with function body.
