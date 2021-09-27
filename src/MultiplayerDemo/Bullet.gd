extends Area2D

var created_by = 'me'
var initialSpeed = 600
var velocity = Vector2(initialSpeed, 0)

func _physics_process(delta):
	position += velocity * delta

# Destroy the bullet once it leaves the screen
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
