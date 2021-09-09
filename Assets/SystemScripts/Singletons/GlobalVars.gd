extends Node

var camera = null
var peer_type = null

var server_map_data
var server_player

var self_netID

const TILE_OFFSET = 2.0

const NON_TRAVERSABLES = ['Wall', 'TempWall']
const BLOCKS_VISION = ['Wall', 'TempWall']

const OBJ_SPAWNER = preload("res://Assets/SystemScripts/ObjectSpawner.gd")
var obj_spawner = OBJ_SPAWNER.new()

const PLAYER_OBJ_SPAWNER = preload("res://Assets/SystemScripts/ObjectSpawner4Player.gd")
var plyr_obj_spawner = PLAYER_OBJ_SPAWNER.new()
