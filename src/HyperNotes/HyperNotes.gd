extends "res://src/ResizeRoot.gd"

onready var fileContent = $HBoxContainer/VBoxContainer/FileContent
onready var saver = $HyperGateway/SaveContent
onready var loader = $HyperGateway/GetContent
onready var filePathInput = $HBoxContainer/VBoxContainer/HBoxContainer/FilePathInput
onready var fileLister = $HyperGateway/ListFiles
onready var fileTree = $HBoxContainer/Files
onready var fileChanges = $HyperGateway/FileChanges

export var source = "hyper://notes/"

func _on_SaveButton_pressed():
	saver.save(filePathInput.text, fileContent.text)
	pass

func _on_LoadButton_pressed():	
	loader.getContent(filePathInput.text)
	pass # Replace with function body.

func _on_GetContent_content(content):
	fileContent.text = content
	pass # Replace with function body.

func _on_ListFiles_files(files):
	fileTree.clear()
	if files.size() == 0:
		var root = fileTree.create_item()
		root.set_text(0, "No Files Found")
		return
	
	var root = fileTree.create_item()
	root.set_text(0, source)
	for file in files:
		var child = fileTree.create_item(root)
		child.set_text(0, file)
	pass

func _on_Files_item_selected():
	var item = fileTree.get_selected()
	var text = item.get_text(0)
	var path = source + text
	
	print('Loading', path)
	
	filePathInput.text = path
	loader.getContent(path)
	pass # Replace with function body.

func _on_FileChanges_change():
	fileLister.list(source)
	pass # Replace with function body.


func _on_HyperGateway_started_gateway(_pid):
	fileChanges.request(source)
	fileLister.list(source)
	loader.getContent(filePathInput.text)
