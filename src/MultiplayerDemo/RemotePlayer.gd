extends "res://src/MultiplayerDemo/PlayerSprite.gd"

var velocity = Vector2()

func update_position(new_position, new_rotation, new_velocity):
	position = new_position
	rotation_degrees = new_rotation
	velocity = new_velocity

func _physics_process(_delta):
	velocity = move_and_slide(velocity)
