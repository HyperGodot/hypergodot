extends KinematicBody2D

func _on_VisibilityNotifier2D_screen_exited():
	var viewport = get_viewport_rect().size
	position.x = viewport.x / 2
	position.y = viewport.y / 2
