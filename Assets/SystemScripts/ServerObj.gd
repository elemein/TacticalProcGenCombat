extends Node

var network = NetworkedMultiplayerENet.new()
var network_api = MultiplayerAPI.new()

var port = 7369
var max_players = 32

var player_list = []

func _ready():
	create_server()

func _process(delta):
	if custom_multiplayer.has_network_peer() == false: return
	custom_multiplayer.poll()

func create_server():
	self.name = 'Server'
	network.create_server(port, max_players)
	set_custom_multiplayer(network_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	print("@@@@@@@@@@@@@ Server started.")
	
	network.connect("peer_connected", self, "_player_connected")
	network.connect("peer_disconnected", self, "_player_disconnected")

func _player_connected(id):
	print('@@@@@@@Player ' + str(id) + ' has connected!')
	player_list.append(id)
	
func _player_disconnected(id):
	print('Goodbye player ' + str(id) + '.')

remote func verifyme(verifmessage):
	print('verified ' + str(verifmessage))
	print(custom_multiplayer.get_rpc_sender_id())
	rpc_id(player_list[0], 'say_message', 'here is my message')
