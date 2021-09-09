extends Node

var peer = NetworkedMultiplayerENet.new()
var port = 7369
var max_players = 32

var player_list = []

func _ready():
	pass # Replace with function body.

func create_server():
	GlobalVars.peer_type = 'server'
	peer.create_server(port, max_players)
	get_tree().network_peer = peer
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	print("Server opened successfully on port " + str(port))
	player_list.append(GlobalVars.server_player)
	GlobalVars.self_netID = 1

func _player_connected(id):
	print('Player ' + str(id) + ' has connected!')
	
	var spawn_to_map = GlobalVars.server_player.get_parent_map()
	var spawn_to_pos = GlobalVars.server_player.get_map_pos()
	spawn_to_pos[1] += 1
	
	var new_player = GlobalVars.obj_spawner.spawn_actor('PlagueDoc', spawn_to_map, spawn_to_pos, true)
	var player_id = new_player.get_id()
	player_id['NetID'] = id
	new_player.set_id(player_id)
	player_list.append(new_player)
	
	rpc_id(id, "receive_id_from_server", id)

func _player_disconnected(id):
	print('Goodbye player ' + str(id) + '.')
	for player in player_list:
		if player.get_id()['NetID'] == id:
			player.get_parent_map().remove_map_object(player)
			player_list.erase(player)

func request_map_from_server():
	print("Requesting map from server.")
	rpc_id(1, "send_map_to_requester", get_instance_id())

remote func send_map_to_requester(requester):
	var player_id = get_tree().get_rpc_sender_id()
	var map_data = PlayerInfo.current_map.return_map_grid_encoded_to_string()
	print(map_data)
	print("Sending map data to requester.")
	rpc_id(player_id, 'receive_map_from_server', map_data)

remote func receive_map_from_server(map_data):
	GlobalVars.server_map_data = map_data
	print(map_data)


remote func receive_id_from_server(id):
	GlobalVars.self_netID = id
