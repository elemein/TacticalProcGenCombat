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
	MultiplayerTestenv.create_server()
	MultiplayerTestenv.create_client()
	
	GlobalVars.peer_type = 'server'
	reference_path = 'res://Assets/GUI/CharacterSelect/CharacterSelect.tscn'
	var _result = get_tree().change_scene(reference_path)
