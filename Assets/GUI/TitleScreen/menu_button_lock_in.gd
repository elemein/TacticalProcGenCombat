extends Button

export var reference_path = ""
export(bool) var start_focused = false

func _ready():
	if start_focused:
		grab_focus()
		
	var _result = connect("mouse_entered", self, "_on_button_mouse_entered")
	_result = connect("pressed", self, "_on_button_pressed")
	
func _on_button_mouse_entered():
	grab_focus()
	
func _on_button_pressed():
	if GlobalVars.peer_type == 'server':
		reference_path = 'res://World.tscn'
	elif GlobalVars.peer_type == 'client':
		reference_path = 'res://PlayerWorld.tscn'
	
	var _result = get_tree().change_scene(reference_path)
	
	GlobalVars.client_state = 'ingame'
