extends "res://src/ResizeRoot.gd"

signal profile_ready(url)

export var profile_URL: String = 'hyper://flyballs-profile/'
export var profile_file: String = 'profile.json'
export var cache_folder: String = 'user://hyper-file-cache/'

var picture_name = ""
var picture_path = ""

func _ready():
	var dir = Directory.new()
	var err = dir.make_dir_recursive(cache_folder)
	if err != OK:
		printerr("Unable to create cache directory ", err)

func hide_loader():
	$Loader.hide()
	$Form.show()

func show_loader():
	$Loader.show()
	$Form.hide()

func load_url():
	var url_record = profile_URL + '.well-known/hyper'
	$LoadURLRequest.request(url_record)

func update_profile(data):
	var json = JSON.print(data)
	var info_url = profile_URL + profile_file

	$UpdateProfileRequest.request(info_url, [], true, HTTPClient.METHOD_PUT, json)

func get_username():
	return $Form/UsernameInput.text

func load_profile():
	var info_url = profile_URL + profile_file
	$ListInfoRequest.request(info_url)

func load_image(image: String):
	print('Loading image')
	show_loader()
	var file_name = image.get_file()
	picture_path = cache_folder + file_name
	# TODO: Save file_path somewhere?
	$LoadImageRequest.download_file = picture_path
	$LoadImageRequest.request(image)

func _on_ImageChooser_pressed():
	$FileDialog.popup()

func _on_FileDialog_file_selected(path: String):
	show_loader()

	picture_name = path.get_file()	
	var picture_url = profile_URL + picture_name

	$HyperUploader.upload_file(picture_url, path)

func _on_HyperGateway_started_gateway(_pid):
	load_profile()

func _on_ListInfoRequest_request_completed(_result, response_code, _headers, body):
	if response_code != 200:
		printerr('Cannot load existing profile info: ', response_code)
		hide_loader()
		return
	
	var parsed = JSON.parse(body.get_string_from_utf8())
	if parsed.error != OK:
		printerr(parsed.error_string)
		hide_loader()
		return
	
	$Form/StartButton.disabled = false
	
	$Form/UsernameInput.text = parsed.result.username

	var image = parsed.result.image
	if image != null:
		load_image(image)
	else: hide_loader()

func _on_HyperUploader_uploaded(url, response_code):
	if response_code != 200:
		printerr('Unable to upload file ')
		hide_loader()
		return

	if !url || (url.length() == 0):
		printerr("Unable to load Link header for image.")
		hide_loader()
		return

	update_profile({
		"username": get_username(),
		"image": url
	})

	load_image(url)

func _on_UploadFileRequest_request_completed(_result, response_code, headers, body):
	print('Uploaded picture')
	if response_code != 200:
		printerr('Unable to upload: ', body.get_string_from_utf8())
		return
	
	var regex = RegEx.new()
	regex.compile("link: <(.+)>")
	var final_url = ''
	
	for header in headers:
		var result = regex.search(header)
		final_url = result.get_string(1)
	
	if !final_url || (final_url.size() == 0):
		printerr("Unable to load Link header for image. ", headers)
		hide_loader()
		return

	update_profile({
		"username": get_username(),
		"image": final_url
	})

func _on_LoadImageRequest_request_completed(result, response_code, _headers, body):
	hide_loader()
	if result != OK or response_code != 200:
		printerr('Unable to load image: ', result, ": ", body.get_string_from_utf8())
		return

	print(result, ' Image got downloaded: ', picture_path)

	var texture = ImageTexture.new()
	var image = Image.new()
	image.load(picture_path)
	texture.create_from_image(image)
	texture.set_size_override(Vector2(64, 64))

	$Form/ImageChooser.icon = texture

func _on_UpdateProfileRequest_request_completed(_result, _response_code, _headers, _body):
	hide_loader()
	$Form/StartButton.disabled = false

func _on_StartButton_pressed():
	show_loader()
	load_url()

func _on_LoadURLRequest_request_completed(result, response_code, _headers, body: PoolByteArray):
	if result != OK or response_code != 200:
		printerr('Unable to load final profile URL')
		return

	var lines = body.get_string_from_utf8()
	var url = lines.split('\n')[0]
	if !url.ends_with('/'):
		url += '/'
	print('Profile ready')
	print(url)
	emit_signal('profile_ready', url)
