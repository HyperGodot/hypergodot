extends "./PlayerSprite.gd"

var Bullet = preload("res://src/MultiplayerDemo/Bullet.tscn")

export (int) var speed = 200

signal shoot(bullet, direction, location)
signal moved(position, rotation, velocity)

var velocity = Vector2()

func proccess_input():
	var hasMoved = false
	look_at(get_global_mouse_position())
	velocity = Vector2()
	if Input.is_action_pressed("right"):
		hasMoved = true
		velocity.x += 1
	if Input.is_action_pressed("left"):
		hasMoved = true
		velocity.x -= 1
	if Input.is_action_pressed("down"):
		hasMoved = true
		velocity.y += 1
	if Input.is_action_pressed("up"):
		hasMoved = true
		velocity.y -= 1

	velocity = velocity.normalized() * speed
	
	if Input.is_action_just_pressed("click"):
		emit_signal("shoot", Bullet, rotation, position)

	return hasMoved

func _physics_process(_delta):
	var hasMoved = proccess_input()
	velocity = move_and_slide(velocity)
	if hasMoved: emit_signal("moved", position, rotation, velocity)
