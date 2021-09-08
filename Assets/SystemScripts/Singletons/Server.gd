extends Node

var peer = NetworkedMultiplayerENet.new()
var port = 7369
var max_players = 32

var player_id_list = []

func _ready():
	pass # Replace with function body.

func create_server():
	GlobalVars.peer_type = 'server'
	peer.create_server(port, max_players)
	get_tree().network_peer = peer
	get_tree().connect("network_peer_connected", self, "_player_connected")
	print("Server opened successfully on port " + str(port))

func _player_connected(id):
	print('player ' + str(id) + ' has connected!')
	player_id_list.append(id)

remote func request_map(requester):
	var player_id = get_tree().get_rpc_sender_id()
	var map_data = PlayerInfo.current_map.map_grid
	print("Sending map data to requester.")
	rpc_id(player_id, 'receive_map_from_server', map_data)

func request_map_from_server():
	print("Requesting map from server.")
	rpc_id(1, "request_map", get_instance_id())
	
remote func receive_map_from_server(map_data):
	print(map_data)
