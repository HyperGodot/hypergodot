extends Node

class_name HTTPEventSource

const URLParser = preload('./utils/URLParser.gd')

signal event(data, event, id)

var http = HTTPClient.new()
var urlParser = URLParser.new()

func cancel_request():
	http.close()
	pass

func request(
	url,
	custom_headers = [],
	ssl_validate_domain=true,
	method =0,
	request_data=""
):
	var headers = ["Accept: text/event-stream"]
	headers.append_array(custom_headers)
	var parsedURL = urlParser.parse(url)
	var use_ssl = parsedURL.protocol == 'https'

	var params = {
		"headers": headers,
		"host": parsedURL.host,
		"port": parsedURL.port,
		"path": parsedURL.path,
		"use_ssl": use_ssl,
		"verify_host": use_ssl && ssl_validate_domain,
		"method": method,
		"request_data": request_data
	}
	
	print('About to request', parsedURL, params)

	var thread = Thread.new()
	
	thread.start(self,"_runRequest", params)

	pass

func _runRequest(params):
	var err = http.connect_to_host(params.host, params.port, params.use_ssl, params.verify_host)
	
	print('Connected to host')
	
	# Wait to establish a connection to the host
	while http.get_status() == HTTPClient.STATUS_CONNECTING or http.get_status() == HTTPClient.STATUS_RESOLVING:
		http.poll()
		OS.delay_msec(100)
		
	print('Able to connect, requesting')
		
	# Start the request
	err = http.request(params.method, params.path, params.headers, params.request_data)
	
	# Wait for request to get processed and to get the body
	while (http.get_status() == HTTPClient.STATUS_REQUESTING):
		http.poll()
		OS.delay_msec(100)
	
	if !http.has_response():
		print('No Response')
		http.close()
		call_deferred("emit_signal", "response_finished")
		return

	var statusCode = http.get_response_code()
	var responseHeaders = http.get_response_headers()
	
	print('Got response ', statusCode)
	
	call_deferred("emit_signal", "response_started", statusCode, responseHeaders)
	
	var buffer = ""
	var lastChunkEmpty = false
	var currentEvent = {
		"event": "message",
		"data": "",
		"id": ""
	}

	while http.get_status() == HTTPClient.STATUS_BODY:
		http.poll()
		var chunk = http.read_response_body_chunk().get_string_from_utf8()
		if(chunk.length() == 0):
			var delay = 800 if lastChunkEmpty else 200
			lastChunkEmpty = true
			OS.delay_usec(delay)
			continue
		lastChunkEmpty = false
		buffer = buffer + chunk

		while buffer.find("\n") != -1:
			var line = buffer.substr(0, buffer.find("\n"))
			buffer = buffer.substr(buffer.find("\n") + 1)

			if line.find("data:") == 0: currentEvent["data"] += line.trim_prefix("data:")
			if line.find("id:") == 0: currentEvent["id"] = line.trim_prefix("id:")
			if line.find("event:") == 0: currentEvent["event"] = line.trim_prefix("event:")

			var isEmpty = line.length() == 0
			if isEmpty:
				call_deferred("emit_signal", "event", currentEvent.data, currentEvent.event, currentEvent.id)
				currentEvent = {
					"event": "message",
					"data": "",
					"id": ""
				}
	http.close()
	print('Done!')
	call_deferred("emit_signal", "response_finished")
pass


func _emitEvent(params):
	emit_signal("event", params.data, params.name, params.id)
	pass
