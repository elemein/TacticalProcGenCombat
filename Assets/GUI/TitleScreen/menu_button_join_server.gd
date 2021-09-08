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
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client('127.0.0.1', 7369)
	get_tree().network_peer = peer
