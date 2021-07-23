extends HyperEventSource

signal change

func listen(path):
	request(path)

func _on_FileChanges_event(data, event, id):
	print('Event ', event, data)
	if event == "change":
		emit_signal("change")
