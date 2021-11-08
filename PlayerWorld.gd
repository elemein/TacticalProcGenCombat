extends Node

const MAPSET = preload("res://Assets/SystemScripts/Mapset.gd")
var map_set = MAPSET.new(null, null)

const MAP_UNPACKER = preload("res://Assets/SystemScripts/MapUnpacker.gd")
var map_unpacker = MAP_UNPACKER.new()

func _ready():
	load_new_map()

func load_new_map():
	GlobalVars.clear_maps()
	var map_data = MultiplayerTestenv.get_client().map_data
	map_set.name = map_data['Parent Mapset Name']
	var unpacked_map = map_unpacker.unpack_map(map_data)

	add_child(map_set)
	GlobalVars.total_mapsets.append(map_set)
	map_set.add_map_to_mapset(unpacked_map)
	map_set.organize_child_map_nodes()
	
	MultiplayerTestenv.get_client().get_client_obj().find_and_render_viewfield()
	MultiplayerTestenv.get_client().set_client_state('ingame')
	
#	CommBus.notify_server_map_loaded(unpacked_map.get_map_server_id())
