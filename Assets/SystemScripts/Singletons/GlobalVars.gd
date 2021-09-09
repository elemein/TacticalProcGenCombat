extends Node

var camera = null
var peer_type = null

const TILE_OFFSET = 2.0

const NON_TRAVERSABLES = ['Wall', 'TempWall']
const BLOCKS_VISION = ['Wall', 'TempWall']

const OBJ_SPAWNER = preload("res://Assets/SystemScripts/ObjectSpawner.gd")
var obj_spawner = OBJ_SPAWNER.new()
