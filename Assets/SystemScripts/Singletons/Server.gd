extends Node

var peer = NetworkedMultiplayerENet.new()
var port = 7369
var max_players = 32

func _ready():
	pass # Replace with function body.

func create_server():
	peer.create_server(port, max_players)
	get_tree().network_peer = peer
	get_tree().connect("network_peer_connected", self, "_player_connected")

func _player_connected(id):
	print('player ' + str(id) + ' has connected!')
