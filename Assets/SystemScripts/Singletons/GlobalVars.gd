extends Node

var camera = null
var peer_type = null

var server_mapset
var server_map_data
var server_map_name
var server_player

var total_mapsets = []

var self_netID
var self_instanceID
var self_instanceObj

const TILE_OFFSET = 2.0

const NON_TRAVERSABLES = ['Wall', 'TempWall']
const BLOCKS_VISION = ['Wall', 'TempWall']

const OBJ_SPAWNER = preload("res://Assets/SystemScripts/ObjectSpawner.gd")
var obj_spawner = OBJ_SPAWNER.new()

const PLAYER_OBJ_SPAWNER = preload("res://Assets/SystemScripts/ObjectSpawner4Player.gd")
var plyr_obj_spawner = PLAYER_OBJ_SPAWNER.new()
