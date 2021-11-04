extends Node

var loading_screen = preload('res://Assets/GUI/LoadingScreen/LoadingScreen.tscn')

var rng = RandomNumberGenerator.new()

var camera = null
var peer_type = null

var server_mapset
var server_map_data
var server_map_name

# Possible states: ['ingame', 'loading', 'character select']
var client_state

var total_mapsets = []
var total_maps = []

var self_obj : ActorObj
var self_netID : int

const TILE_OFFSET = 2.0

const OBJ_SPAWNER = preload("res://Assets/SystemScripts/ObjectSpawner.gd")
var obj_spawner = OBJ_SPAWNER.new()

var default_settings = {
	'Server IP': ''
}

func _ready():
	rng.randomize()

# Getters
func get_self_obj(): return self_obj
func get_self_instance_id(): return self_obj.get_id()['Instance ID']
func get_self_netid(): return self_netID

func get_client_state(): return client_state

# Setters
func set_self_obj(obj): self_obj = obj
func set_self_netID(netid): self_netID = netid

func set_client_state(state): 
	client_state = state
	
	if state == 'loading':
		add_child(loading_screen.instance())
	else:
		var to_remove = get_node('/root/GlobalVars/LoadingScreen')
		remove_child(to_remove)
