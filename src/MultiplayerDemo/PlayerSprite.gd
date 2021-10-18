extends KinematicBody2D

export var radius: float = 30 setget set_radius
export var has_profile = false

func load_profile(profile_url):
	has_profile = true
	$PlayerProfile.url = profile_url
	$PlayerProfile.load_profile()

func set_texture(texture):
	$Sprite.texture = texture
	$Particles2D.texture = texture
	set_radius(radius)

func _on_VisibilityNotifier2D_screen_exited():
	var viewport = get_viewport_rect().size
	position.x = viewport.x / 2
	position.y = viewport.y / 2

func set_radius(radius):
	_set_sprite_radius(radius)
	_set_colission_radius(radius)
	_set_visibility_radius(radius)

func _set_sprite_radius(radius):
	var sprite = $Sprite
	var rect = sprite.get_rect()
	var xCurrent = rect.size.x
	var yCurrent = rect.size.y

	var xScale = (radius * 2) / xCurrent
	var yScale = (radius * 2) / yCurrent

	sprite.scale.x = xScale
	sprite.scale.y = yScale

func _set_colission_radius(radius):
	$CollisionShape2D.shape.radius = radius

func _set_visibility_radius(radius):
	var rect = Rect2(-radius, -radius, radius*2, radius*2)
	$VisibilityNotifier2D.rect = rect

func _on_PlayerProfile_image(path):
	var texture = ImageTexture.new()
	var image = Image.new()
	image.load(path)
	texture.create_from_image(image)
	set_texture(texture)
