extends Node

const MAPSET = preload("res://Assets/SystemScripts/Mapset.gd")
var map_set = MAPSET.new(null, null)

const MAP_UNPACKER = preload("res://Assets/SystemScripts/MapUnpacker.gd")
var map_unpacker = MAP_UNPACKER.new()

func _ready():
	load_new_map()

func load_new_map():
	GlobalVars.clear_maps()
	self.map_set.name = GlobalVars.server_map_data['Parent Mapset Name']
	var unpacked_map = self.map_unpacker.unpack_map(GlobalVars.server_map_data)

	add_child(self.map_set)
	GlobalVars.total_mapsets.append(self.map_set)
	self.map_set.add_map_to_mapset(unpacked_map)
	self.map_set.organize_child_map_nodes()
	
	GlobalVars.get_self_obj().find_and_render_viewfield()
	
	Server.notify_server_map_loaded(unpacked_map.get_map_server_id())
	Signals.emit_signal("world_loaded")
