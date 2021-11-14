extends Node

var loading_screen = preload('res://Assets/GUI/LoadingScreen/LoadingScreen.tscn')

# for self_obj
var player_cam = preload('res://Assets/Objects/PlayerObjects/PlayerCam.tscn')
var player_light = preload('res://Assets/Objects/PlayerObjects/PlayerOmniLight.tscn')

var rng = RandomNumberGenerator.new()

var camera = null
var peer_type = null

var server_map_data

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
	self.rng.randomize()

# Getters
func get_self_obj(): return self_obj
func get_self_instance_id(): return self_obj.get_id()['Instance ID']
func get_self_netid(): return self_netID

func get_client_state(): return client_state

func clear_maps():
	self.total_maps = []
	self.total_mapsets = []

# Setters
func set_self_obj(obj): 
	if obj != null:
		self.self_obj = obj
		self.self_obj.update_id('NetID', self.self_netID)
		self.self_obj.connect_to_status_bars()
		self.self_obj.add_child(self.player_light.instance())
		self.self_obj.add_child(self.player_cam.instance())

func set_self_netID(netid): self_netID = netid

func set_client_state(state): 
	self.client_state = state
	
	if state == 'loading':
		add_child(self.loading_screen.instance())
	else:
		var to_remove = get_node('/root/GlobalVars/LoadingScreen')
		remove_child(to_remove)
