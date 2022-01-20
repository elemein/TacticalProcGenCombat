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
	if GlobalVars.peer_type == 'server':
		self.reference_path = 'res://Objects/Map/World.tscn'
	elif GlobalVars.peer_type == 'client':
		self.reference_path = 'res://Scripts/Map/Generation/PlayerWorld.tscn'
	
	var _result = get_tree().change_scene(self.reference_path)
