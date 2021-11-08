extends Node

var network = NetworkedMultiplayerENet.new()
var network_api = MultiplayerAPI.new()

func _ready():
	create_client()
	
func _process(delta):
	if get_custom_multiplayer() == null: return
	if not custom_multiplayer.has_network_peer(): return
	custom_multiplayer.poll()

func create_client():
	self.name = 'Client'

	network.create_client('127.0.0.1', 7369)
	network.connect("connection_succeeded", self, "_connected_ok")
	network.connect("connection_failed", self, "_connected_fail")
	
	set_custom_multiplayer(network_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)

func _connected_ok():
	print("@@@@@@@Connected to server successfully.")
	rpc_id(1, "verifyme", "verification message")

func _connected_fail():
	print("@@@@@@@Failed to connect to server.")
	
remote func say_message(message):
	print(message)
