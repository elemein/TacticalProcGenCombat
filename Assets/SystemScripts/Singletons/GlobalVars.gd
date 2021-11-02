extends Node

var loading_screen = preload('res://Assets/GUI/LoadingScreen/LoadingScreen.tscn')

var camera = null
var peer_type = null

var server_mapset
var server_map_data
var server_map_name
var server_player : ActorObj

var client_state

var total_mapsets = []

var self_netID : int
var self_instanceID
var self_instanceObj : ActorObj

var in_loading = false

const TILE_OFFSET = 2.0

const NON_TRAVERSABLES = ['Wall', 'TempWall']
const BLOCKS_VISION = ['Wall', 'TempWall']

const OBJ_SPAWNER = preload("res://Assets/SystemScripts/ObjectSpawner.gd")
var obj_spawner = OBJ_SPAWNER.new()

var default_settings = {
	'Server IP': ''
}

func set_loading(state): 
	in_loading = state
	if in_loading:
		client_state = 'loading'
		add_child(loading_screen.instance())
	else:
		var to_remove = get_node('/root/GlobalVars/LoadingScreen')
		remove_child(to_remove)
