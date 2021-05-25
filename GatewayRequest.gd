extends HTTPRequest

signal loaded_data(data)
signal loading_data(url)
signal failed_load(url, error)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func requestHyper(url):
	var toload = url.replace("hyper://", "http://127.0.0.1:4973/hyper/")
	print("Loading " + toload)
	request(toload)
	pass


func _on_request_completed(result, response_code, headers, body):
	print("Result", result)
	print("Response Code", response_code)
	if response_code != 200:
		var message = body.get_string_from_utf8()
		print("Error message:", message)
		emit_signal("failed_load", result, message)
	else: emit_signal("loaded_data", body.get_string_from_utf8())
	pass # Replace with function body.
