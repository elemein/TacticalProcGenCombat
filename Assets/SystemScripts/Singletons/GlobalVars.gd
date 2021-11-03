extends Node

var loading_screen = preload('res://Assets/GUI/LoadingScreen/LoadingScreen.tscn')

var rng = RandomNumberGenerator.new()

var camera = null
var peer_type = null

var server_mapset
var server_map_data
var server_map_name
var server_player : ActorObj

# Possible states: ['ingame', 'loading', 'character select']
var client_state

var total_mapsets = []
var total_maps = []

var self_netID : int
var self_instanceID
var self_instanceObj : ActorObj

const TILE_OFFSET = 2.0

const BLOCKS_VISION = ['Wall', 'TempWall']

const OBJ_SPAWNER = preload("res://Assets/SystemScripts/ObjectSpawner.gd")
var obj_spawner = OBJ_SPAWNER.new()

var default_settings = {
	'Server IP': ''
}

func _ready():
	rng.randomize()
