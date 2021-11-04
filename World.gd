extends Node

var map_name = 'The Cave'

const MAPSET_CLASS = preload("res://Assets/SystemScripts/Mapset.gd")
var dungeon = MAPSET_CLASS.new(map_name, 3)

var mapsets = []

func _ready():	
	catalog_dungeon_to_server()
	create_server_player_and_spawn_to_map()

	GlobalVars.server_map_name = map_name
	GlobalVars.get_self_obj().name = 'Player1'

	Server.create_server()

	Signals.emit_signal("world_loaded")
	GlobalVars.set_client_state('ingame')

func create_server_player_and_spawn_to_map():
	var first_floor
	for mapset in GlobalVars.total_mapsets:
		if mapset.dungeon_name == 'The Cave':
			first_floor = mapset.floors['Dungeon Floor 1']
	
	var first_floor_start_tile = first_floor.get_map_start_tile()
	
	var server_player = GlobalVars.obj_spawner.spawn_actor('Player', \
						first_floor, first_floor_start_tile, true)
	
	GlobalVars.set_self_obj(server_player)
	GlobalVars.get_self_obj().update_id('NetID', 1)
	
	Server.player_list.append(GlobalVars.get_self_obj())
	
	GlobalVars.get_self_obj().find_and_render_viewfield()

func catalog_dungeon_to_server():
	add_child(dungeon)
	mapsets = [dungeon]
	
	for mapset in mapsets:
		GlobalVars.total_mapsets.append(mapset)
		for level in mapset.floors:
			GlobalVars.total_maps.append(mapset.floors[level])

func remove_obj_from_old_map(object):
	Server.object_action_event(object.get_id(), {"Command Type": "Remove From Map"})
	object.set_action('idle') # prevents using the last map's move action on the next map

func move_to_map(object, map):
	remove_obj_from_old_map(object)
	
	map.add_map_object(object, map.get_map_start_tile())
	
	map.print_map_grid()
	
	# de-render everything from old map.
	for obj in object.view_finder.objs_visible_to_player_last_turn: obj.visible = false
	
	Server.resolve_all_viewfields(map)
	
	if object.get_id()['NetID'] != 1:
		Server.move_client_to_map(object, map)
	
	Server.object_action_event(object.get_id(), {"Command Type": "Spawn On Map"})
