extends Button

onready var loading_icon : TextureRect = get_parent().find_node('Loading')
onready var input_box : LineEdit = get_parent().find_node('ServerIPInput')

export var reference_path = 'res://Gui/Menu/CharacterSelect/CharacterSelect.tscn'
export(bool) var start_focused = false

func _ready():
	if self.start_focused:
		grab_focus()
		
	var _result = connect("mouse_entered", self, "_on_button_mouse_entered")
	_result = connect("pressed", self, "_on_button_pressed")
	
	save_server_ip('file')
	
func _on_button_mouse_entered():
	grab_focus()
	
func _on_button_pressed():
	GlobalVars.peer_type = 'client'
	Client.set_server_ip(self.input_box.text)
	Client.connect_to_server()
	
	save_server_ip()
	
	self.loading_icon.visible = true
	while self.loading_icon.visible:
		self.loading_icon.rect_rotation = self.loading_icon.rect_rotation + 1
		yield(get_tree(), "idle_frame")
	
func on_successful_connect():
	self.loading_icon.visible = false
	GlobalVars.set_client_state('character select')
	self.reference_path = 'res://Gui/Menu/CharacterSelect/CharacterSelect.tscn'
	var _result = get_tree().change_scene(self.reference_path)

func on_unsuccessful_connect():
	self.loading_icon.visible = false
	print("Failed to join")
	get_parent().find_node('ServerIPInput').text = 'Failed To Connect'
	
func save_server_ip(preference = 'text_box'):
	var settings_file = File.new()
	
	# Read the current save file and set the IP to the most recent one
	settings_file.open('user://settings.json', File.READ)
	var json_settings = parse_json(settings_file.get_line())
	if json_settings == null:
		json_settings = GlobalVars.default_settings
	if preference == 'file':
		self.input_box.text = json_settings['Server IP']
	else:
		json_settings['Server IP'] = self.input_box.text
	settings_file.close()
	
	# Save the given ip for future use
	settings_file.open('user://settings.json', File.WRITE)
	settings_file.store_line(to_json(json_settings))
	settings_file.close()
