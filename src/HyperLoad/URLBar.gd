extends LineEdit

signal url(url)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func navigate():
	var url = text
	if url.begins_with("hyper://"):
		emit_signal("url", url)
	pass # Replace with function body.


func _on_URLBar_text_entered(_new_text):
	navigate()
	pass # Replace with function body.
