extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func setLoaded():
	text = "Status: Loaded"
	pass # Replace with function body.

func setLoading(url):
	text = "Status: Loading " + url
	pass # Replace with function body.


func setError(error):
	text = "Status: Failed Load" + error
	pass # Replace with function body.


func setGatewayLoading():
	text = "Status: Starting Gateway"
	pass # Replace with function body.


func setGatewayLoaded(pid):
	text = "Status: Gateway Loaded"
	pass # Replace with function body.


func _on_HyperLoad_request_completed(result, response_code, headers, body):
	print("Response Code ", response_code)
	if response_code != 200:
		var message = body.get_string_from_utf8()
		print("Error message:", message)
		setError(message)
	else: setLoaded()
	pass # Replace with function body.
