extends Button

export var reference_path = ""
export(bool) var start_focused = false

func _ready():
	if self.start_focused:
		grab_focus()
		
	var _result = connect("mouse_entered", self, "_on_button_mouse_entered")
	_result = connect("pressed", self, "_on_button_pressed")
	
func _on_button_mouse_entered():
	grab_focus()
	
func _on_button_pressed():
	if self.reference_path == 'res://World.tscn' && GlobalVars.peer_type == 'client':
		self.reference_path = 'res://PlayerWorld.tscn'
		var _result = get_tree().change_scene(self.reference_path)
	elif self.reference_path == 'res://Assets/GUI/CharacterSelect/CharacterSelect.tscn':
		GlobalVars.peer_type = 'server'
		var _result = get_tree().change_scene(self.reference_path)
	elif self.reference_path != "":
		var _result = get_tree().change_scene(self.reference_path)
	else:
		get_tree().quit()
