extends "res://src/ResizeRoot.gd"

# TODO: Better error dialogs

signal profile_ready(url)

export var level_url = 'hyper://flyballs-level/'
export var spawn_gateway = true

func _ready():
	if spawn_gateway: $HyperGateway.start()

func load_level():
	print("Initial level load")
	$LevelInfo.url = level_url
	$LevelInfo.load_info()

func hide_loader():
	$Loader.hide()
	$Form.show()

func show_loader():
	$Loader.show()
	$Form.hide()

func get_title():
	return $Form/TitleInput.text

func load_image(image: String):
	print('Loading image')
	show_loader()
	$LevelInfo.download_image(image)

func _on_ImageChooser_pressed():
	print('Choosing image')
	$FileDialog.popup()

func _on_FileDialog_file_selected(path: String):
	print('Selected image, uploading:', path)
	show_loader()
	$LevelInfo.upload_image(path)

func _on_HyperGateway_started_gateway(_pid):
	load_level()

func _on_StartButton_pressed():
	print("Starting next step")
	show_loader()
	$LevelInfo.update({
		"title": get_title()
	})
	$LevelInfo.resolve_url()

func _on_LevelInfo_error(err):
	# TODO: Show an error dialog?
	print("Error interacting with profile:", err)

func _on_LevelInfo_image(path):
	print("Image loaded, setting texture")
	hide_loader()
	var texture = ImageTexture.new()
	var image = Image.new()
	image.load(path)
	texture.create_from_image(image)
	texture.set_size_override(Vector2(64, 64))

	$Form/ImageChooser.icon = texture

func _on_LevelInfo_info(info):
	print("Loaded level info:", info)
	$Form/StartButton.disabled = false
	$Form/TitleInput.text = info.title

	if info.has('image') && info.image.length() != 0:
		load_image(info.image)
	else: hide_loader()

func _on_LevelInfo_updated():
	print('Updated level info"')
	hide_loader()
	$Form/StartButton.disabled = false

func _on_LevelInfo_resolved(url):
	print('Profile ready')
	print(url)
	emit_signal('profile_ready', url)

func _on_LevelInfo_no_info():
	print('No existing profile info')
	hide_loader()
