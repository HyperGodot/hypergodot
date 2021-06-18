extends RichTextLabel

func _on_HyperLoad_request_completed(result, response_code, headers, body):
	text = body.get_string_from_utf8()
	pass # Replace with function body.
