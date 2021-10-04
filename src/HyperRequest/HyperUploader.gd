extends Node

class_name HyperUploader

# Final URL of upload along with status code
signal uploaded(url, status)
signal error(e)

var URLParser = preload("res://src/utils/URLParser.gd")

export var serverPrefix = "http://127.0.0.1:4973/hyper/"

# TODO: Actually use threads
# export var use_threads = true

var request: HTTPClient = HTTPClient.new()
var parser = URLParser.new()

func cancel_request():
	request.close()

func _connect_to_gateway():
	var parsed = parser.parse(serverPrefix)
	var port = parsed.port
	var host = parsed.host
	var use_ssl = parsed.ssl
	
	print('Connecting to gateway for upload: ', host, ":", port)
	var err = request.connect_to_host(host, port, use_ssl, true)
	
	if err != OK:
		return err
	
	# Wait to establish a connection to the host
	while request.get_status() == HTTPClient.STATUS_CONNECTING or request.get_status() == HTTPClient.STATUS_RESOLVING:
		err = request.poll()
		if err != OK:
			printerr('Unable to connect to EventSource')
			return err
		OS.delay_msec(100)

	return OK

func upload_file(url, filePath):
	# Connect to gateway
	_connect_to_gateway()
	# Open file
	var file = File.new()
	var err = file.open(filePath, File.READ)

	if err != OK:
		printerr('Unable to open file for upload')
		return _emit_err(err)
	
	var parsedServer = parser.parse(serverPrefix)
	var parsedURL = parser.parse(url)

	var final_url = parsedServer.path + parsedURL.host + parsedURL.path
	
	print('PUT ', final_url, " <- ", filePath)
	err = _perform_file_upload(final_url, file)
	
	file.close()

	if err != OK:
		printerr("Unable to make file upload request")
		return _emit_err(err)
	
	err = _wait_for_finish()
	
	if err != OK:
		return _emit_err(err)
		
	var statusCode = request.get_response_code()
	var headers = request.get_response_headers()

	var regex = RegEx.new()
	regex.compile("link: <(.+)>")
	var resolve_url = ''
	
	for header in headers:
		var result = regex.search(header)
		if !result: continue
		resolve_url = result.get_string(1)

	emit_signal('uploaded', resolve_url, statusCode)

	return OK

func _perform_file_upload(absolute_url, file: File):
	var length = file.get_len()
	var buffer = file.get_buffer(length)
	var headers = []

	return request.request_raw(HTTPClient.METHOD_PUT, absolute_url, headers, buffer)

func _wait_for_finish():
	print('Waiting to finish upload')
	# Wait for request to get processed and to get the body
	while (request.get_status() == HTTPClient.STATUS_REQUESTING):
		var err = request.poll()
		if err != OK:
			printerr('Error getting request from upload')
			return err
		OS.delay_msec(100)
	
	if !request.has_response():
		printerr('No Response from upload')
		request.close()
		return ERR_CANT_OPEN

	print("Loading upload response")

	while request.get_status() == HTTPClient.STATUS_BODY:
		var err = request.poll()
		if err != OK:
			printerr('Error loading body from upload')
			return err
		print(request.read_response_body_chunk().get_string_from_utf8())
		OS.delay_usec(100)
	
	print('Finished loading upload response')

	return OK

func _exit_tree():
	cancel_request()

func _emit_err(e):
	printerr('Error uploadng file: ', e)
	emit_signal('error', e)
	return e
