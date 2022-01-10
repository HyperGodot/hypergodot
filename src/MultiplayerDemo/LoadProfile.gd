extends "res://src/ResizeRoot.gd"

# TODO: Better error dialogs
# TODO: Better UX for updating the username

signal profile_ready(url)

export var profile_url = 'hyper://flyballs-profile/'
export var spawn_gateway = true

func _ready():
	if spawn_gateway: $HyperGateway.start()

func load_profile():
	print("Initial profile load")
	$PlayerProfile.url = profile_url
	$PlayerProfile.load_info()

func hide_loader():
	$Loader.hide()
	$Form.show()

func show_loader():
	$Loader.show()
	$Form.hide()

func get_username():
	return $Form/UsernameInput.text

func load_image(image: String):
	print('Loading image')
	show_loader()
	$PlayerProfile.download_image(image)

func _on_ImageChooser_pressed():
	print('Choosing image')
	$FileDialog.popup()

func _on_FileDialog_file_selected(path: String):
	print('Selected image, uploading:', path)
	show_loader()
	$PlayerProfile.upload_image(path)

func _on_HyperGateway_started_gateway(_pid):
	load_profile()

func _on_StartButton_pressed():
	print("Starting next step")
	show_loader()
	$PlayerProfile.update_info({
		"username": get_username()
	})
	$PlayerProfile.resolve_url()

func _on_PlayerProfile_error(err):
	# TODO: Show an error dialog?
	print("Error interacting with profile:", err)

func _on_PlayerProfile_image(path):
	print("Image loaded, setting texture")
	hide_loader()
	var texture = ImageTexture.new()
	var image = Image.new()
	image.load(path)
	texture.create_from_image(image)
	texture.set_size_override(Vector2(64, 64))

	$Form/ImageChooser.icon = texture

func _on_PlayerProfile_info(info):
	print("Loaded player profile:", info)
	$Form/StartButton.disabled = false
	$Form/UsernameInput.text = info.username

	if info.has('image') && info.image.length() != 0:
		load_image(info.image)
	else: hide_loader()

func _on_PlayerProfile_updated():
	print('Updated player profile"')
	hide_loader()
	$Form/StartButton.disabled = false

func _on_PlayerProfile_resolved(url):
	print('Profile ready')
	print(url)
	emit_signal('profile_ready', url)

func _on_PlayerProfile_no_info():
	print('No existing profile info')
	hide_loader()
