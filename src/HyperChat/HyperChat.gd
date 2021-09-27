extends "res://src/ResizeRoot.gd"

const LRU = preload('res://src/utils/LRU.gd')

# Messages are JSON which contain {id, from, username, type, content}
# All messages have a username and type
# Some messages contain a `from` for peer that sent the message
# If no `from` field is visible, it means it's from the sending peer
# type: 'text` will have `content` of the text message that got sent
# type: 'identity' will have empty `content`, and is there to notify peers of this users existence

# GET peer list to start registering for extensions
# Set up list of seen remotePublicKeys
# Broadcast self after a second of waiting for peers
# Broadcast self on name change
# Broadcast self when seeing a new remotePublicKey

export var archiveRoot = 'hyper://blog.mauve.moe/'
#export var archiveRoot = 'hyper://70338a94d7415990ab4a3160cf98a5d940243d7fa24dd297352e66b52d3ff841/'
export var extensionName = 'hyperchat-example-1'

var extensionsFolder = archiveRoot + '$/extensions/'
var extensionPath = extensionsFolder + extensionName

var seen_messages = LRU.new()
var seen_identities = LRU.new()

onready var eventSource = $HyperGateway/HyperEventSource
onready var gateway = $HyperGateway
onready var chatBox = $ScrollContainer/ChatBox
onready var chatText = $HBoxContainer/ChatInput
onready var username = $HBoxContainer/Username
onready var broadcastRequest = $HyperGateway/BroadcastRequest
onready var listPeersRequest = $HyperGateway/ListPeersRequest

func _ready():
	# Initialize random number generator
	randomize()
	gateway.start()

func display_item(from, content):
	# Add to item list	
	chatBox.text += from + ': ' + content + "\n" 

func send_current():
	var text = chatText.text
	chatText.text = ""
	display_item(get_username(), text)
	broadcast_text(text)

func update_identity(_from, username):
	# Have some sort of sidebar to display known users?	
	display_item('System', 'Seen user ' + username)
	pass
	
func list_peers():
	listPeersRequest.request(extensionPath)

func _on_text_message(data, _from):
	# TODO: Something fancy with the `from` attribute?
	display_item(data.username, data.content)
	
func _on_identity_message(_data, from):
	var isNew = !has_seen_identity(from)

	# Track identity
	seen_identities.track(from)

	# If it's new, broadcast your own identity
	if isNew:
		broadcast_identity()

func _on_unknown_message(data, from):
	# Emit some sort of error?
	printerr("Got unknown message", from, data)

func get_username():
	return username.text

func broadcast_text(content):
	var username = get_username()
	broadcast_message({
		'type': 'text',
		'content': content,
		'username': username
	})

func broadcast_identity():
	var username = get_username()
	broadcast_message({
		'type': 'identity',
		'username': username
	})

func broadcast_message(message):
	# POST to extension URL	
	if !("id" in message):
		message.id = make_id()
	seen_messages.track(message.id)
	print('Broadcasting message', message, extensionPath)
	var body = JSON.print(message)
	broadcastRequest.request(extensionPath,[], false, HTTPClient.METHOD_POST, body)

func has_seen_identity(from):
	return seen_identities.has(from)

func has_seen_message(id):
	return seen_messages.has(id)

func re_broadcast(message, from):
	if !("from" in message):
		message.from = from
	broadcast_message(message)

func handle_message(message, from):
	var finalFrom = message.from if "from" in message else from
	if !("id" in message):
		return _on_unknown_message(message, finalFrom)
	if has_seen_message(message.id):
		return

	re_broadcast(message, finalFrom)
	match message.type:
		'text':
			_on_text_message(message, finalFrom)
		'identity':
			_on_identity_message(message, finalFrom)
		_:
			_on_unknown_message(message, finalFrom)

func _on_event(data, _event, id):
	var parsed = JSON.parse(data)
	
	if parsed.error != OK:
		printerr("Unable to parse EventSource content " + parsed.error_line + "\n" + data)
		return
	
	handle_message(parsed.result, id)

func make_id():
	return str(randi()) + str(randi())

func start_listening():
	eventSource.request(extensionsFolder)	

func _on_HyperEventSource_event(data, event, id):
	_on_event(data, event, id)

func _on_HyperGateway_started_gateway(_pid):
	start_listening()
	list_peers()
	broadcast_identity()

func _on_SendButton_pressed():
	send_current()
	pass # Replace with function body.

func _on_ChatInput_text_entered(_new_text):
	send_current()
	pass # Replace with function body.
