extends Node

var URLParser = preload("res://src/utils/URLParser.gd")
var parser = URLParser.new()

signal info(info)
signal no_info()
signal image(path)
signal updated()
signal resolved(url)
signal error(err)

export var url = 'hyper://blog.mauve.moe/'
export var cache_folder: String = 'user://hyper-file-cache/'
export var profile_file: String = 'profile.json'

export var autoload = false
export var autoload_image = false
export var defaults = {}

var info_cache = null
var has_loaded = false
var picture_path = ''

func _ready():
	var dir = Directory.new()
	var err = dir.make_dir_recursive(cache_folder)
	if err != OK:
		printerr("Unable to create cache directory ", err)
	
	print("Profile setup")
	if autoload:
		load_info()

func get(field):
	if info_cache != null and info_cache.has(field):
		return info_cache[field]
	if defaults.has(field):
		return defaults.get(field)

func update_info(updates):
	var data = {}

	if info_cache != null:
		for key in info_cache.keys():
			data[key] = info_cache[key]
	else:
		for key in defaults:
			data[key] = defaults[key]

	for key in updates.keys():
		data[key] = updates[key]

	var json = JSON.print(data)
	var info_url = url + profile_file
	
	$updateInfoRequest.request(info_url, [], true, HTTPClient.METHOD_PUT, json)

	info_cache = data

func load_info():
	var info_url = url + profile_file
	$loadInfoRequest.request(info_url)

func resolve_url():
	var url_record = url + '.well-known/hyper'
	$resolveURLRequest.request(url_record)

func download_image(image_url: String):
	print('Loading image: ', image_url)
	var file_name = image_url.get_file()
	var key = parser.parse(image_url).host
	# Save the picture with the profile key prefixed to it
	picture_path = cache_folder + key + '-' + file_name
	$loadImageRequest.download_file = picture_path
	$loadImageRequest.request(image_url)

func upload_image(path: String):
	var picture_name = path.get_file()
	var picture_url = url + picture_name

	$uploader.upload_file(picture_url, path)

func _on_loadInfoRequest_request_completed(_result, response_code, _headers, body):
	print("Loaded info", _result, " ", response_code)
	if response_code != 200:
		printerr('Cannot load existing profile info: ', response_code)
		emit_signal("no_info")
		return
	
	var parsed = JSON.parse(body.get_string_from_utf8())
	if parsed.error != OK:
		printerr(parsed.error_string)
		emit_signal("no_info")
		return
	
	info_cache = parsed.result

	var image = info_cache.image
	
	emit_signal("info", info_cache)
	
	if image != null and autoload_image:
		download_image(image)

func _on_uploader_uploaded(resolved_url, response_code):
	if response_code != 200:
		printerr('Unable to upload file ')
		return

	if !url || (url.length() == 0):
		printerr("Unable to load Link header for image.")
		return

	update_info({
		"image": resolved_url
	})

	download_image(resolved_url)

func _on_loadImageRequest_request_completed(result, response_code, _headers, body):
	if result != OK or response_code != 200:
		printerr('Unable to load image: ', result, ": ", body.get_string_from_utf8())
		return

	print(result, ' Image got downloaded: ', picture_path)
	
	emit_signal('image', picture_path)

func _on_updateInfoRequest_request_completed(_result, _response_code, _headers, _body):
	emit_signal("updated")

func _on_resolveURLRequest_request_completed(result, response_code, _headers, body: PoolByteArray):
	if result != OK or response_code != 200:
		printerr('Unable to load final profile URL')
		return

	var lines = body.get_string_from_utf8()
	var resolved_url = lines.split('\n')[0]
	if !resolved_url.ends_with('/'):
		resolved_url += '/'

	emit_signal('resolved', resolved_url)
