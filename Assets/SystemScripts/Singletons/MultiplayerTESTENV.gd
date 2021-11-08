extends Node

const SERVER_CLASS = preload("res://Assets/SystemScripts/ServerObj.gd")
const CLIENT_CLASS = preload("res://Assets/SystemScripts/ClientObj.gd")

func _ready():
	pass
#	create_server()
#	create_client()

func create_server():
	var server = SERVER_CLASS.new()
	add_child(server)

func create_client():
	var client = CLIENT_CLASS.new()
	add_child(client)
