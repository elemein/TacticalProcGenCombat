extends Node

const TILE_OFFSET = 2.1

const NON_TRAVERSABLES = ['Wall', 'TempWall', 'Imp', 'Fox']
const BLOCKS_VISION = ['Wall', 'TempWall']
const ENEMY_TYPES = ['Imp', 'Fox']

const OBJ_SPAWNER = preload("res://Assets/SystemScripts/ObjectSpawner.gd")
var obj_spawner = OBJ_SPAWNER.new()
