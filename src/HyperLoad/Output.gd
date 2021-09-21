extends RichTextLabel

func _on_HyperLoad_request_completed(_result, _response_code, _headers, body):
	text = body.get_string_from_utf8()
	pass # Replace with function body.
