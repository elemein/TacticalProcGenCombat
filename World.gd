extends Node

# When traversing maps, the previous map is destroyed so that it does not interfere
# with the new one. This isnt desirable behaviour as it completely prevents backtracking.
# Have this sorted for v0.1

var map_name = 'The Cave'

const BASE_PLAYER = preload("res://Assets/Objects/PlayerObjects/Player.tscn")
var player = BASE_PLAYER.instance()

const MAPSET_CLASS = preload("res://Assets/SystemScripts/Mapset.gd")
var dungeon = MAPSET_CLASS.new(map_name, 3)

var mapsets = []

func _ready():
	GlobalVars.self_instanceID = player.get_id()['Instance ID']
	GlobalVars.self_instanceObj = player
	
	add_child(dungeon)
	mapsets = [dungeon]
	
	for mapset in mapsets:
		GlobalVars.total_mapsets.append(mapset)
		for level in mapset.floors:
			GlobalVars.total_maps.append(mapset.floors[level])
	
	move_to_map(player, map_name, 1)
	
	GlobalVars.self_instanceObj.find_and_render_viewfield()
	
	# Put the player on the first floor and clean up the garbage
	var player_child = dungeon.get_node('Floor1/Players/Player')
	player_child.get_parent().remove_child(player_child)
	dungeon.get_node('Floor1/Players').add_child(player_child)
	
	### NETWORK
	if GlobalVars.peer_type == 'server' and GlobalVars.self_netID != 1: 
		GlobalVars.server_map_name = map_name
		player_child.name = 'Player1'
		Server.create_server()

	elif GlobalVars.peer_type == 'client': 
		Server.request_map_from_server()
		
	else:
		Server.player_list.append(GlobalVars.server_player)
	Signals.emit_signal("world_loaded")

func return_map_w_mapset_and_id(targ_mapset_name, target_map_id):
	var targ_mapset
	for map in mapsets:
		if map.get_mapset_name() == targ_mapset_name:
			targ_mapset = map
	
	var floor_dict = targ_mapset.get_floors()
	for flr in floor_dict.values():
		if flr.map_id == target_map_id:
			return flr
	
	return 'Map ID not found in mapset.'

func get_mapset_from_name(mapset_name):
	for mapset in mapsets:
		if mapset.get_mapset_name() == mapset_name:
			return mapset

func remove_obj_from_old_map(object):
	var curr_map = object.get_parent_map()
	if typeof(curr_map) != TYPE_STRING:
		curr_map.get_turn_timer().remove_from_timer_group(object)
		
		Server.object_action_event(object.get_id(), {"Command Type": "Remove From Map"})
		
		object.set_action('idle') # prevents using the last map's move action on the next map

func move_to_map(object, mapset_name, target_map_id):
	remove_obj_from_old_map(object)
	
	var targ_map = return_map_w_mapset_and_id(mapset_name, target_map_id)
	object.set_parent_map(targ_map)
	var player_pos = targ_map.place_player_on_map(object)
	object.set_map_pos_and_translation(player_pos)
	
	targ_map.print_map_grid()
	
	object.find_and_render_viewfield()
	
	if object.get_id()['NetID'] != 1:
		Server.move_client_to_map(object, targ_map)
	
	Server.object_action_event(object.get_id(), {"Command Type": "Spawn On Map"})
