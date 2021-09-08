extends Node

var server_ip = '127.0.0.1'
var server_port = 7369

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func connect_to_server():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(server_ip, server_port)
	get_tree().network_peer = peer
