extends Node

const MAPSET = preload("res://Assets/SystemScripts/Mapset.gd")
var map_set = MAPSET.new(null, null)

const PLYR_PLY_MAP = preload("res://Assets/SystemScripts/PlayerPlayMap.gd")
#var plyr_play_map = PLYR_PLY_MAP.new()

const PSIDE_ROOM_CLASS = preload("res://Assets/SystemScripts/PSideRoom.gd")

const MAP_UNPACKER = preload("res://Assets/SystemScripts/MapUnpacker.gd")
var map_unpacker = MAP_UNPACKER.new()

func _ready():
	load_new_map()

func load_new_map():
	map_set.name = GlobalVars.server_map_data['Parent Mapset Name']
	var unpacked_map = map_unpacker.unpack_map(GlobalVars.server_map_data)

	add_child(map_set)
	GlobalVars.total_mapsets.append(map_set)
	map_set.add_map_to_mapset(unpacked_map)
	map_set.organize_child_map_nodes()
	
	GlobalVars.get_self_obj().find_and_render_viewfield()
	Signals.emit_signal("world_loaded")
