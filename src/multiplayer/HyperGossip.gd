extends Node

class_name HyperGossip

const LRU = preload('res://src/utils/LRU.gd')

signal listening(extension_name)
signal event(type, data, from)
signal peers(peers)

export var url = "hyper://blog.mauve.moe/"
export var extension_name = "hyper-gossip-v1"

var peerListRequest = HyperRequest.new()
var eventSource = HyperEventSource.new()
var broadcastRequest = HyperRequest.new()

var seen_messages = LRU.new()
var requestQueue = []
var isRequesting = false

func _ready():
	add_child(peerListRequest)
	peerListRequest.connect("request_completed", self, "_on_peer_list")

	add_child(broadcastRequest)
	broadcastRequest.connect("request_completed", self, "_on_broadcast_completed")

	add_child(eventSource)
	eventSource.connect("event", self, "_on_event")
	eventSource.connect("response_started", self, "_on_events_started")

func start_listening():
	load_peers()
	eventSource.request(_get_extension_listen_url())

func _on_events_started(_statusCode, _responseHeaders):
	emit_signal("listening", extension_name)

func _enqueue_broadcast_request(reqURL, body):
	if isRequesting:
		requestQueue.push_back({"reqURL": reqURL, "body": body})
	else: _perform_broadcast_request(reqURL, body)
	
func _perform_broadcast_request(reqURL, body):
	isRequesting = true
	broadcastRequest.request(reqURL, [], false, HTTPClient.METHOD_POST, body)

func _on_broadcast_completed(_result, _response_code, _headers, _body):
	isRequesting = false
	if requestQueue.size() == 0: return
	var next = requestQueue.pop_front()
	_perform_broadcast_request(next.reqURL, next.body)

func rebroadcast(event):
	var reqURL = _get_extension_url()
	var body = JSON.print(event)
	_enqueue_broadcast_request(reqURL, body)

func broadcast_event(type: String, data):
	var reqURL = _get_extension_url()
	var body = JSON.print(_generateEvent(type, data))
	_enqueue_broadcast_request(reqURL, body)
	
func send_to_peer(peer, type, data):
	var reqURL = _get_extension_url_to_peer(peer)
	var body = JSON.print(_generateEvent(type, data))
	_enqueue_broadcast_request(reqURL, body)

func load_peers():
	var reqURL = _get_extension_url()
	peerListRequest.request(reqURL)

func _generateEvent(type, data):
	var id = _make_id()
	seen_messages.track(id)
	return {
		"id": id,
		"type": type,
		"data": data
	}

func _handle_event(event):
	var type = event.type
	var data = event.data
	var id = event.id
	var from = event.from
	
	if seen_messages.has(id):
		return
	
	seen_messages.track(id)
	
	emit_signal("event", type, data, from)
	rebroadcast(event)

func _on_event(data, event, id):
	# Ignore events for other extensions
	if event != extension_name: return

	var parsed = JSON.parse(data)
	
	if parsed.error != OK:
		printerr("Unable to parse EventSource content " + parsed.error_line + "\n" + data)
		return
	
	var result = parsed.result
	if !("from" in result):
		result.from = id

	_handle_event(result)
	

func _on_peer_list(_result, response_code, _headers, body):
	var text = body.get_string_from_utf8()
	if response_code != 200:
		printerr('Error listing peers ', response_code, " ", text)
		return

	var parsed = JSON.parse(text)

	if parsed.error != OK:
		printerr("Unable to parse Peer List" + String(parsed.error_line))
		return
		
	var peers = parsed.result

	emit_signal("peers", peers)

func _get_extension_url_to_peer(peer):
	return url + '$/extensions/' + extension_name + '/' + peer

func _get_extension_url():
	return url + '$/extensions/' + extension_name

func _get_extension_listen_url():
	return url + '$/extensions/'

func _make_id():
	return str(randi()) + str(randi())
