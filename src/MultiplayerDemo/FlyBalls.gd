extends Node2D

var PlayerSprite = preload("res://src/MultiplayerDemo/PlayerSprite.tscn")

export var url: String = "hyper://blog.mauve.moe/"

onready var gossip = $HyperGossip
onready var player = $Player
onready var gateway = $HyperGateway

const POSITION = 'position'

const knownPlayers = {}

func _ready():
	gateway.start()

func get_player_object(id):
	if knownPlayers.has(id): return knownPlayers[id]

	var playerSprite = PlayerSprite.instance()
	knownPlayers[id] = playerSprite

	_broadcast_player()

	return playerSprite

func _broadcast_player():
	var position = player.position
	var rotation = player.rotation_degrees
	var data = {
		"position": {
			"x": position.x,
			"y": position.y
		},
		"rotation": rotation
	}
	gossip.broadcast_event(POSITION, data)

func _on_remote_player_moved(positionData, id):
	var remotePlayer = get_player_object(id)
	var rotation_degrees = positionData.rotation
	var raw_position = positionData.position
	remotePlayer.rotation_degrees = rotation_degrees
	remotePlayer.position.x = raw_position.x
	remotePlayer.position.y = raw_position.y

func _on_Player_shoot(Bullet, direction, location):
	var bullet = Bullet.instance()
	add_child(bullet)
	bullet.rotation = direction
	bullet.position = location
	bullet.velocity = bullet.velocity.rotated(direction)

func _on_HyperGateway_started_gateway(_pid):
	gossip.url = url
	gossip.start_listening()

func _on_HyperGossip_listening(_extension_name):
	print('Started listening on events')
	# Tell everyone we exist!
	_broadcast_player()

func _on_HyperGossip_event(type, data, from):
	if type == POSITION:
		_on_remote_player_moved(data, from)

func _on_Player_moved(_position, _rotation, _velocity):
	# TODO: Don't broadcast too often to avoid flooding the system
	_broadcast_player()
