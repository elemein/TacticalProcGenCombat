extends Node

# When traversing maps, the previous map is destroyed so that it does not interfere
# with the new one. This isnt desirable behaviour as it completely prevents backtracking.
# Have this sorted for v0.1

const MAPSET_CLASS = preload("res://Assets/SystemScripts/Mapset.gd")
var dungeon = MAPSET_CLASS.new('The Cave', 3)

const PLYR_PLY_MAP = preload("res://Assets/SystemScripts/PlayerPlayMap.gd")
var plyr_play_map = PLYR_PLY_MAP.new()

var mapsets = []

func _ready():
	add_child(plyr_play_map)
	unpack_map(GlobalVars.server_map_data)
	
	first_turn_workaround_for_player_sight()

func unpack_map(map_data):
	GlobalVars.total_mapsets.append(plyr_play_map)
	plyr_play_map.set_map_server_id(map_data[0])
	map_data = map_data[1]
	var map_grid = []
	
	GlobalVars.server_mapset = plyr_play_map
	print('Unpacking map.')
	for x in range(map_data.size()):
		map_grid.append([])
		for z in range(map_data[0].size()):
			map_grid[x].append([])
			for obj in range(map_data[x][z].size()):
				var object = map_data[x][z][obj][0]
				
				match object['Identifier']:
					'BaseGround': 
						var ground = GlobalVars.plyr_obj_spawner.spawn_map_object(object['Identifier'], [x,z])
						plyr_play_map.add_child(ground)
						ground.update_id('Instance ID', object['Instance ID'])
						ground.set_parent_map(plyr_play_map)
						map_grid[x][z].append(ground)
					'BaseWall': 
						var wall = GlobalVars.plyr_obj_spawner.spawn_map_object(object['Identifier'], [x,z])
						plyr_play_map.add_child(wall)
						wall.update_id('Instance ID', object['Instance ID'])
						wall.set_parent_map(plyr_play_map)
						map_grid[x][z].append(wall)
					'PlagueDoc': 
						if object['NetID'] == GlobalVars.self_netID:
							var client_player = GlobalVars.plyr_obj_spawner.spawn_actor('PSidePlayer', [x,z])
							plyr_play_map.add_child(client_player)
							Server.add_player_to_local_player_list(client_player)
							client_player.update_id('NetID', GlobalVars.self_netID)
							client_player.update_id('Instance ID', object['Instance ID'])
							client_player.set_map_pos(client_player.get_id()['Position'])
							map_grid[x][z].append(client_player)
							
							GlobalVars.self_instanceObj = client_player
						else:
							var other_player = GlobalVars.plyr_obj_spawner.spawn_actor(object['Identifier'], [x,z])
							plyr_play_map.add_child(other_player)
							Server.add_player_to_local_player_list(other_player)
							other_player.update_id('NetID', object['NetID'])
							other_player.update_id('Instance ID', object['Instance ID'])
							map_grid[x][z].append(other_player)
					'Fox':
						var fox = GlobalVars.plyr_obj_spawner.spawn_actor(object['Identifier'], [x,z])
						plyr_play_map.add_child(fox)
						fox.update_id('Instance ID', object['Instance ID'])
						fox.set_parent_map(plyr_play_map)
						map_grid[x][z].append(fox)
					'Imp':
						var imp = GlobalVars.plyr_obj_spawner.spawn_actor(object['Identifier'], [x,z])
						plyr_play_map.add_child(imp)
						imp.update_id('Instance ID', object['Instance ID'])
						imp.set_parent_map(plyr_play_map)
						map_grid[x][z].append(imp)
	
	plyr_play_map.set_map_grid(map_grid)
	print('Map unpacked.')

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
	GlobalVars.self_instanceObj.find_viewfield()
	GlobalVars.self_instanceObj.resolve_viewfield_to_screen()
	
#	player.get_parent_map().hide_non_visible_from_player()
