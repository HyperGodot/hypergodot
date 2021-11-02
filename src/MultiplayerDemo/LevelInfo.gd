extends Node

var URLParser = preload("res://src/utils/URLParser.gd")
var parser = URLParser.new()

signal info(title, image)
signal no_info()
signal image(path)
signal updated()
signal resolved(url)
signal error(err)

export var url = 'hyper://multiplayer-level/'
export var cache_folder: String = 'user://hyper-file-cache/'
export var level_file: String = 'level.json'

export var autoload = false
export var autoload_image = false

const DEFAULT_TITLE = 'New Level'

var info_cache = null
var has_loaded = false
var picture_path = ''

func _ready():
	var dir = Directory.new()
	var err = dir.make_dir_recursive(cache_folder)
	if err != OK:
		printerr("Unable to create cache directory ", err)
	
	print("Level info setup")
	if autoload:
		load_info()

func get_title():
	if info_cache == null: return DEFAULT_TITLE
	if !info_cache.has('title'): return DEFAULT_TITLE
	return info_cache.title

func set_title(title):
	update_info({
		"title": title
	})

func update_info(updates):
	var data = {}

	if info_cache != null:
		for key in info_cache.keys():
			data[key] = info_cache[key]

	for key in updates.keys():
		data[key] = info_cache[key]

	var json = JSON.print(data)
	var info_url = url + level_file

	$updateInfoRequest.request(info_url, [], true, HTTPClient.METHOD_PUT, json)

func load_info():
	var info_url = url + level_file
	$loadInfoRequest.request(info_url)

func resolve_url():
	var url_record = url + '.well-known/hyper'
	$resolveURLRequest.request(url_record)

func download_image(url: String):
	print('Loading image: ', url)
	var file_name = url.get_file()
	var key = parser.parse(url).host
	# Save the picture with the profile key prefixed to it
	picture_path = cache_folder + key + '-' + file_name
	$loadImageRequest.download_file = picture_path
	$loadImageRequest.request(url)

func upload_image(path: String):
	var picture_name = path.get_file()
	var picture_url = url + picture_name

	$uploader.upload_file(picture_url, path)

func _on_loadInfoRequest_request_completed(_result, response_code, _headers, body):
	print("Loaded info", _result, " ", response_code)
	if response_code != 200:
		printerr('Cannot load existing level info: ', response_code)
		emit_signal("no_info")
		return
	
	var parsed = JSON.parse(body.get_string_from_utf8())
	if parsed.error != OK:
		printerr(parsed.error_string)
		emit_signal("no_info")
		return
	
	info_cache = parsed.result

	var title = info_cache.title
	var image = info_cache.image
	
	emit_signal("info", title, image)
	
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
	var url = lines.split('\n')[0]
	if !url.ends_with('/'):
		url += '/'
	emit_signal('resolved', url)
