extends Node

const SERVER_CLASS = preload("res://Assets/SystemScripts/TESTING_INFRASTRUCTURE/ServerObj.gd")
const CLIENT_CLASS = preload("res://Assets/SystemScripts/TESTING_INFRASTRUCTURE/ClientObj.gd")

var server
var client

func create_server():
	server = SERVER_CLASS.new()
	add_child(server)

func create_client():
	client = CLIENT_CLASS.new()
	add_child(client)

func get_client(): return client
func get_server(): return server
