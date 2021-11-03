extends Node

var map_name = 'The Cave'

const MAPSET_CLASS = preload("res://Assets/SystemScripts/Mapset.gd")
var dungeon = MAPSET_CLASS.new(map_name, 3)

var mapsets = []

func _ready():	
	catalog_dungeon_to_server()
	create_server_player_and_spawn_to_map()

	### NETWORK
	if GlobalVars.peer_type == 'server' and GlobalVars.self_netID != 1: 
		GlobalVars.server_map_name = map_name
		GlobalVars.self_instanceObj.name = 'Player1'
		Server.create_server()

	elif GlobalVars.peer_type == 'client': 
		Server.request_map_from_server()
	
	Signals.emit_signal("world_loaded")

func create_server_player_and_spawn_to_map():
	var first_floor
	for mapset in GlobalVars.total_mapsets:
		if mapset.dungeon_name == 'The Cave':
			first_floor = mapset.floors['Dungeon Floor 1']
	
	var first_floor_start_tile = first_floor.get_map_start_tile()
	
	var server_player = GlobalVars.obj_spawner.spawn_actor('Player', \
						first_floor, first_floor_start_tile, true)
						
	
	GlobalVars.self_instanceID = server_player.get_id()['Instance ID']
	GlobalVars.self_instanceObj = server_player
	
	GlobalVars.self_instanceObj.find_and_render_viewfield()

func catalog_dungeon_to_server():
	add_child(dungeon)
	mapsets = [dungeon]
	
	for mapset in mapsets:
		GlobalVars.total_mapsets.append(mapset)
		for level in mapset.floors:
			GlobalVars.total_maps.append(mapset.floors[level])

func get_mapset_from_name(mapset_name):
	for mapset in mapsets:
		if mapset.get_mapset_name() == mapset_name:
			return mapset

func remove_obj_from_old_map(object):
	var curr_map = object.get_parent_map()
	if typeof(curr_map) != TYPE_STRING:
		curr_map.remove_map_object(object)
		
		Server.object_action_event(object.get_id(), {"Command Type": "Remove From Map"})
		
		object.set_action('idle') # prevents using the last map's move action on the next map

func move_to_map(object, map):
	remove_obj_from_old_map(object)
	
	object.set_parent_map(map)
	
	object.set_map_pos_and_translation(map.get_map_start_tile())
	map.add_map_object(object)
	
	map.print_map_grid()
	
	Server.resolve_all_viewfields(map)
	
	if object.get_id()['NetID'] != 1:
		Server.move_client_to_map(object, map)
	
	Server.object_action_event(object.get_id(), {"Command Type": "Spawn On Map"})
