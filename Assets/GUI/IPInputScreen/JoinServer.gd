extends Button

export var reference_path = 'res://Assets/GUI/CharacterSelect/CharacterSelect.tscn'
export(bool) var start_focused = false

func _ready():
	if start_focused:
		grab_focus()
		
	var _result = connect("mouse_entered", self, "_on_button_mouse_entered")
	_result = connect("pressed", self, "_on_button_pressed")
	
func _on_button_mouse_entered():
	grab_focus()
	
func _on_button_pressed():
	GlobalVars.peer_type = 'client'
	Client.set_server_ip(get_parent().find_node('ServerIPInput').text)
	Client.connect_to_server()
	
func on_successful_connect():
	reference_path = 'res://Assets/GUI/CharacterSelect/CharacterSelect.tscn'
	var _result = get_tree().change_scene(reference_path)

func on_unsuccessful_connect():
	print("Failed to join")
	get_parent().find_node('ServerIPInput').text = 'Failed To Connect'
