extends Node2D

var RemotePlayer = preload("res://src/MultiplayerDemo/RemotePlayer.tscn")
var RemoteBullet = preload("res://src/MultiplayerDemo/RemoteBullet.tscn")

#export var url: String = "hyper://blog.mauve.moe/"
export var url: String = "hyper://70338a94d7415990ab4a3160cf98a5d940243d7fa24dd297352e66b52d3ff841/"
export var profile : String = ""
export var spawn_gateway = true

onready var gossip = $HyperGossip
onready var player = $Player
onready var gateway = $HyperGateway

const POSITION = 'position'
const SHOOT = 'shoot'

const knownPlayers = {}

func _ready():
	if spawn_gateway: gateway.start()
	elif profile.length() != 0: player.load_profile(profile)

func get_player_object(id):
	if knownPlayers.has(id): return knownPlayers[id]

	var remotePlayer = RemotePlayer.instance()
	knownPlayers[id] = remotePlayer

	add_child(remotePlayer)
	_broadcast_player()

	return remotePlayer

func _broadcast_player():
	var position = player.position
	var rotation = player.rotation_degrees
	var velocity = player.velocity
	var data = {
		"profile": profile,
		"position": {
			"x": position.x,
			"y": position.y
		},
		"velocity": {
			"x": velocity.x,
			"y": velocity.y
		},
		"rotation": rotation
	}
	print('Broadcasting', data)
	gossip.broadcast_event(POSITION, data)

func _broadcast_shoot(direction,location):
	var data = {
		"profile": profile,
		"direction": direction,
		"position": {
			"x": location.x,
			"y": location.y
		}
	}

	gossip.broadcast_event(SHOOT, data)

func _on_remote_player_moved(positionData, id):
	# print('Moving player', id, " ", positionData)
	var remotePlayer = get_player_object(id)
	
	if positionData.has('profile') and positionData.profile.length() != 0:
		if !remotePlayer.has_profile: remotePlayer.load_profile(positionData.profile)

	var rotation_degrees = positionData.rotation
	var raw_position = positionData.position
	var raw_velocity = positionData.velocity
	
	remotePlayer.update_position(
		Vector2(raw_position.x, raw_position.y),
		rotation_degrees,
		Vector2(raw_velocity.x, raw_velocity.y)
	)

func _on_remote_player_shoot(positionData, id):
	var direction = positionData.direction
	var raw_position = positionData.position
	var new_position = Vector2(raw_position.x, raw_position.y)

	var bullet = RemoteBullet.instance()
	bullet.rotation = direction
	bullet.position = new_position
	bullet.velocity = bullet.velocity.rotated(direction)
	bullet.created_by = id
	
	add_child(bullet)

func _on_Player_shoot(Bullet, direction, location):
	var bullet = Bullet.instance()
	bullet.rotation = direction
	bullet.position = location
	bullet.velocity = bullet.velocity.rotated(direction)

	add_child(bullet)

	_broadcast_shoot(direction, location)

func _on_HyperGateway_started_gateway(_pid):
	if profile.length() != 0: player.load_profile(profile)

	gossip.url = url
	gossip.start_listening()

func _on_HyperGossip_listening(_extension_name):
	print('Started listening on events')
	# Tell everyone we exist!
	_broadcast_player()

func _on_HyperGossip_event(type, data, from):
	# print("Event ", type, " ", from)
	if type == POSITION:
		_on_remote_player_moved(data, from)
	if type == SHOOT:
		_on_remote_player_shoot(data, from)

func _on_Player_moved(_position, _rotation, _velocity):
	# TODO: Don't broadcast too often to avoid flooding the system
	_broadcast_player()
