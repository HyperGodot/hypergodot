extends "res://src/ResizeRoot.gd"

var FlyBalls = preload("res://src/MultiplayerDemo/FlyBalls.tscn")

func _on_LoadProfile_profile_ready(url):
	remove_child($LoadProfile)

	var game = FlyBalls.instance()
	game.profile = url
	game.spawn_gateway = false
	add_child(game)

func _on_HyperGateway_started_gateway(pid):
	$LoadProfile.load_profile()
