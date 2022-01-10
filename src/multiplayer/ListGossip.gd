extends HyperGossip

signal list_items(items)

class_name ListGossip

export var id_key = 'url'
export var items_event = 'items'

# Enables you to gossip a list of items, useful for game lobbies
var items = []

func _ready():
	._ready()
	connect("event", self, "_on_event_list_gossip")

func add_item(item):
	if !item.has(id_key):
		printerr('Attempted to gossip item without an id key:', id_key, ' ', item)
		return
	
	if !has_item(item):
		items.append(item)
		broadcast_items()

func has_item(item):
	for existing in items:
		if existing[id_key] == item[id_key]:
			return true
	return false

func broadcast_items():
	emit_signal('list_items', items)
	broadcast_event(items_event, {'items': items})

func _on_event_list_gossip(event, data, _from):
	if event != items_event: return
	if !data.has('items'):
		printerr('Gossip without items list', data)
		return
	var hasNew = false
	for item in data.items:
		if !has_item(item):
			hasNew = true
			items.append(item)

	if hasNew: broadcast_items()

