extends "res://src/ResizeRoot.gd"

onready var output = $ScrollContainer/Output
onready var urlInput = $HBoxContainer/URLInput
onready var source = $HTTPEventSource

func _on_URLInput_text_entered(_new_text):
	connectSource()

func _on_Button_pressed():
	connectSource()

func outputText(text):
	output.text += text + '\n'

func connectSource():
	var url = urlInput.text
	outputText('Connecting to: ' + url)
	source.request(url)

func _on_HTTPEventSource_event(data, event, id):
	print(event, '('+ id + '): ', data)
	outputText('id: ' + id)
	outputText('event: ' + event)
	outputText('data: ' + data)

func _on_HTTPEventSource_response_started(status, _headers):
	outputText('Response started (Status ' + str(status) + ')')

func _on_HTTPEventSource_response_finished():
	outputText('Response finished')
