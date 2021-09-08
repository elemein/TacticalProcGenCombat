extends Node

# When traversing maps, the previous map is destroyed so that it does not interfere
# with the new one. This isnt desirable behaviour as it completely prevents backtracking.
# Have this sorted for v0.1

const BASE_PLAYER = preload("res://Assets/Objects/PlayerObjects/Player.tscn")
var player = BASE_PLAYER.instance()

const MAPSET_CLASS = preload("res://Assets/SystemScripts/Mapset.gd")
var dungeon = MAPSET_CLASS.new('The Cave', 3)

var mapsets = []

func _ready():

	add_child(dungeon)
	mapsets = [dungeon]
	
	move_to_map(player, 'The Cave', 1)
	
	first_turn_workaround_for_player_sight()
	
	### NETWORK
	if GlobalVars.peer_type == 'server': 
		Server.create_server()


	
	elif GlobalVars.peer_type == 'client': 
		Server.request_map_from_server()
	


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

func move_to_map(object, mapset_name, target_map_id):
	var targ_map = return_map_w_mapset_and_id(mapset_name, target_map_id)
	
	var curr_map = object.get_parent_map()
	if typeof(curr_map) != TYPE_STRING:
		curr_map.remove_map_object(object)
		curr_map.get_parent_mapset().get_floors().erase(curr_map.get_map_name())
		curr_map.queue_free() # remove the old map so it doesnt overlap and mess shit up with the new one
		
		object.set_action('idle') # prevents using the last map's move action on the next map
	
	object.set_parent_map(targ_map)

	var player_pos = targ_map.place_player_on_map(object)
	object.set_map_pos_and_translation(player_pos)
	
	targ_map.print_map_grid()
	
	first_turn_workaround_for_player_sight()
	
func first_turn_workaround_for_player_sight():
	player.viewfield = player.view_finder.find_view_field(player.get_map_pos()[0], player.get_map_pos()[1])	
	player.get_parent_map().hide_non_visible_from_player()
