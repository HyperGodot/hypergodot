extends "./PlayerSprite.gd"

var Bullet = preload("res://src/MultiplayerDemo/Bullet.tscn")

export (int) var speed = 200

signal shoot(bullet, direction, location)
signal moved(position, rotation, velocity)

var velocity = Vector2()
var old_velocity = Vector2()

func proccess_input():
	look_at(get_global_mouse_position())
	old_velocity = velocity
	velocity = Vector2()
	if Input.is_action_pressed("right"):
		velocity.x += 1
	if Input.is_action_pressed("left"):
		velocity.x -= 1
	if Input.is_action_pressed("down"):
		velocity.y += 1
	if Input.is_action_pressed("up"):
		velocity.y -= 1

	velocity = velocity.normalized() * speed
	
	if Input.is_action_just_pressed("click"):
		emit_signal("shoot", Bullet, rotation, position)
		
	var hasMoved = !velocity.is_equal_approx(old_velocity)

	return hasMoved

func _physics_process(_delta):
	var hasMoved = proccess_input()
	velocity = move_and_slide(velocity)
	if hasMoved: emit_signal("moved", position, rotation, velocity)
