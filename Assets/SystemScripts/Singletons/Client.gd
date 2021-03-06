extends Node

onready var quit_buttons := preload("res://Assets/GUI/MenuButtons/MenuButtons.tscn")
var option_buttons : VBoxContainer = null

# Spare signal connections.
#    get_tree().connect("network_peer_connected", self, "_player_connected")
#    get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
#    get_tree().connect("connected_to_server", self, "_connected_ok")
#    get_tree().connect("connection_failed", self, "_connected_fail")
#    get_tree().connect("server_disconnected", self, "_server_disconnected")

var server_ip = '127.0.0.1'
var server_port = 7369

# Called when the node enters the scene tree for the first time.
func _ready():
	option_buttons = quit_buttons.instance()
	for button in option_buttons.get_children():
		button = button as Button
		button.connect("pressed", self, 'remove_buttons')
	self.add_child(option_buttons)
	option_buttons.visible = false

func connect_to_server():
	GlobalVars.set_loading(true)
	GlobalVars.peer_type = 'client'
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(server_ip, server_port)
	get_tree().network_peer = peer
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_disconnected")
	print("Connecting to server.")

func _connected_ok():
	print("Connected to server successfully.")
	get_node('/root/IPInputScreen/MarginContainer/VBoxContainer/JoinServer').on_successful_connect()
	Server.request_map_from_server()
	GlobalVars.set_loading(false)

func _connected_fail():
	print("Failed to connect to server.")
	get_node('/root/IPInputScreen/MarginContainer/VBoxContainer/JoinServer').on_unsuccessful_connect()
	GlobalVars.set_loading(false)

func set_server_ip(target_ip): server_ip = target_ip

func _disconnected():
	option_buttons.visible = true
	
func remove_buttons():
	option_buttons.visible = false
	
	# Reset server info
	Server.player_list = []
	GlobalVars.server_mapset = null
	GlobalVars.server_map_data = null
	GlobalVars.server_player = null
	GlobalVars.total_mapsets = []
	GlobalVars.self_instanceID = null
	GlobalVars.self_instanceObj = null
