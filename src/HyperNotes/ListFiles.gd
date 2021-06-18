extends "res://src/HyperRequest/HyperRequest.gd"

signal files(files)

export var folder = 'hyper://notes/'

func _ready():
	list()
	pass # Replace with function body.

func list(path=folder):
	request(path + "?noResolve") 
	pass

func _on_ListFiles_request_completed(result, response_code, headers, body):
	print('Loaded', response_code)
	
	if response_code != 200: return
	
	var content = body.get_string_from_utf8()
	
	print("Loaded directory listing", content)
	
	var json = JSON.parse(content)
	
	print("Loaded JSON", json)
	
	if json.error != OK: return printerr(json.error_string)

	emit_signal("files", json.result)
	pass # Replace with function body.
