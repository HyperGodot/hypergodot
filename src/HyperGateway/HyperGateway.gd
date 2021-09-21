extends Node

const URLParser = preload('../utils/URLParser.gd')

class_name HyperGateway

signal starting_gateway()
signal started_gateway(pid)

signal started_download(version)
signal finished_download(version)

export var writable = true
export var persist = true

export var autoStart = true
export var autoDownload = true
export var autoUpdate = false

export var storageDirectory = "user://gateway-data/"
export var repositoryName = "rangermauve/hyper-gateway"
export var tagStart = "v2"

## TODO: Use this tag if the `latest` release doesn't match the tag?
# export var defaultTag = "v2.1.3"

var processPID = 0
var latestInfoRequest = HTTPRequest.new()
var downloadFileRequest = HTTPRequest.new()
var downloadingVersion = null
var downloadThread = null

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		cleanupGateway()
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	ensureStorageLocation()
	add_child(latestInfoRequest)
	latestInfoRequest.connect("request_completed", self, "_on_got_latest")
	
	add_child(downloadFileRequest)
	downloadFileRequest.connect("request_completed", self, "_on_finished_download")
	
	if autoStart:
		start()

func start():
	autoStart = true
	if autoDownload:
		ensureDownloaded()
	else: ensureSetup()

func cleanupGateway():
	if processPID == 0:
		print('Gateway already closed ' + str(processPID)) 
		return
	print('Cleaning up gateway ' + str(processPID))
	OS.kill(processPID)

func setupGateway():
	emit_signal("starting_gateway")
	var executiblePath = getExecutiblePath()
	var path = ProjectSettings.globalize_path(executiblePath)

	var args = ["run"]
	if !persist: args.append('--no-persist')
	if writable: args.append('--writable')
	
	var resolvedStorageDirectory = ProjectSettings.globalize_path(storageDirectory)
	args.append('--storage-location')
	args.append(resolvedStorageDirectory)

	print("Starting gateway from ",path, " with args ", args)

	# Start the hyper-gateway in a process
	processPID = OS.execute(path, args, false)

	# Sleep for a bit while the gateway loads
	# TODO: Find a better indicator like polling the HTTP server socket
	OS.delay_msec(2000)

	print("Started gateway at " + str(processPID))	
	emit_signal("started_gateway", processPID)

func ensureSetup():
	if processPID != 0: return
	setupGateway()

func getExecutibleName():
	var name = OS.get_name()
	if name == 'X11': return "hyper-gateway-linux"
	if name == 'OSX': return "hyper-gateway-macos"
	if name == 'Windows': return "hyper-gateway-windows.exe"
	push_error("Can not start gateway, invalid operating system " + name)

func getCurrentVersion():
	var file = File.new()
	var err = file.open(getVersionFilePath(), File.READ)
	if err != OK:
		printerr('No existing binary version found', err)
		return ""
	var version = file.get_as_text()
	file.close()
	return version

func saveCurrentVersion(version):
	var file = File.new()
	file.open(getVersionFilePath(), File.WRITE)
	file.store_string(version)
	file.close()

func getVersionFilePath():
	return storageDirectory + 'version.txt'

func getExecutiblePath():
	var executibleName = getExecutibleName()
	return storageDirectory  + executibleName

func ensureStorageLocation():
	var dir = Directory.new()
	var err = dir.make_dir_recursive(storageDirectory)
	if err != OK:
		printerr("Unable to create storage directory ", err)

func hasBinary():
	var version = getCurrentVersion()
	return version && version.length()

func ensureDownloaded():
	if autoUpdate || !hasBinary():
		checkLatestVersion()
	elif autoStart:
		ensureSetup()

func checkLatestVersion():
	var url = latestURL()
	print('Getting latest version from ' + url)
	latestInfoRequest.request(url, [], true, HTTPClient.METHOD_GET)
	
func _on_got_latest(_result, response_code, _headers, body):
	print('Latest info response', response_code)
	var parsed = JSON.parse(body.get_string_from_utf8())
	if parsed.error != OK:
		printerr("Unable to parse latest version from GitHub:", parsed.error_string)
		return
	var info = parsed.result
	var newVersion = info.tag_name
	
	print('Latest version:', newVersion)

	var existing = getCurrentVersion()
	
	if newVersion != existing: downloadLatest(info.assets, newVersion)
	elif autoStart: ensureSetup()

func downloadLatest(assets, version):
	var toDownload = null
	var executibleName = getExecutibleName()
	for asset in assets:
		if asset.name != executibleName: continue
		toDownload = asset
	if !toDownload:
		printerr("Unable to find valid executible in latest release")
		return

	var fromURL = toDownload.browser_download_url
	var toPath = getExecutiblePath()

	print('Downloading latest binary:',fromURL)
	
	downloadFileRequest.set_download_file(toPath)
	
	downloadingVersion = version
	emit_signal("started_download", version)
	
	downloadFileRequest.request(fromURL, [], true,HTTPClient.METHOD_GET)

func _on_finished_download(_result, response_code, _headers, _body):
	var executiblePath = getExecutiblePath()
	var path = ProjectSettings.globalize_path(executiblePath)
	var os = OS.get_name()

	# Mark file as executible if not on Windows
	if os != "Windows":
		OS.execute("chmod", ["+x", path])

	print("Finished download ", response_code)
	saveCurrentVersion(downloadingVersion)
	emit_signal("finished_download", downloadingVersion)
	if autoStart: ensureSetup()

func repoURL():
	return "https://api.github.com/repos/" + repositoryName + "/"

func latestURL():
	return repoURL() + "releases/latest"
