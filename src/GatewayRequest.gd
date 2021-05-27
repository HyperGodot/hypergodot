extends HTTPRequest

signal loaded_data(data)
signal loading_data(url)
signal failed_load(url, error)
signal starting_gateway()
signal started_gateway(pid)

var processPID = 0
var storageDirectory = defaultDirectory()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		cleanupGateway()
	pass

func cleanupGateway():
	if processPID == 0:
		print('Gateway already closed ' + str(processPID)) 
		return
	print('Cleaning up gateway ' + str(processPID))
	OS.kill(processPID)
	pass

func setupGateway():
	emit_signal("starting_gateway")
	var executiblePath = getExecutiblePath()
	var executibleFile = File.new()

	executibleFile.open(executiblePath, File.READ)
	
	var path = executibleFile.get_path_absolute()
	executibleFile.close()

	var args = ["run", "--no-persist"]
	
	print("Starting gateway from " + path)
	
	# Start the hyper-gateway in a process
	processPID = OS.execute(path, args, false)

	# Sleep for a bit while the gateway loads
	# TODO: Find a better indicator like polling the HTTP server socket
	OS.delay_msec(2000)

	print("Started gateway at " + str(processPID))	
	emit_signal("started_gateway", processPID)
	pass
	
func ensureSetup():
	if processPID != 0:	return
	setupGateway()
	pass
	
func getExecutiblePath():
	var name = OS.get_name()
	if name == 'X11': return "res://hyper-gateway/hyper-gateway-linux"
	if name == 'OSX': return "res://hyper-gateway/hyper-gateway-macos"
	if name == 'Windows': return "res://hyper-gateway/hyper-gateway-windows.exe"
	push_error("Can not start gateway, invalid operating system " + name)
	pass

func defaultDirectory():
	var dir = Directory.new()
	dir.open('user://gateway-data/')
	return dir.get_current_dir()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func requestHyper(url):
	ensureSetup()
	var toload = url.replace("hyper://", "http://127.0.0.1:4973/hyper/")
	print("Loading " + toload)
	request(toload)
	pass

func _on_request_completed(result, response_code, headers, body):
	print("Response Code ", response_code)
	if response_code != 200:
		var message = body.get_string_from_utf8()
		print("Error message:", message)
		emit_signal("failed_load", result, message)
	else: emit_signal("loaded_data", body.get_string_from_utf8())
	pass # Replace with function body.
