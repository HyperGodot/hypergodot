extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal starting_gateway()
signal started_gateway(pid)

export var processPID = 0
export var serverPrefix = "http://127.0.0.1:4973/hyper/"
export var storageDirectory = 'user://gateway-data/'
export var autoStart = false

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		cleanupGateway()
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	if autoStart: ensureSetup()
	pass # Replace with function body.

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
