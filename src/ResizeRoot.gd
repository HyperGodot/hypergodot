extends VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().get_root().connect("size_changed", self, "fitParent")
	fitParent()
	pass # Replace with function body.

func fitParent():
	var root = get_tree().get_root()
	var rootSize = root.get_size()
	print(rootSize)
	self.set_size(rootSize)
	pass
