extends Node

# When traversing maps, the previous map is destroyed so that it does not interfere
# with the new one. This isnt desirable behaviour as it completely prevents backtracking.
# Have this sorted for v0.1

const MAPSET_CLASS = preload("res://Assets/SystemScripts/Mapset.gd")
var dungeon = MAPSET_CLASS.new('The Cave', 3)

const PLYR_PLY_MAP = preload("res://Assets/SystemScripts/PlayerPlayMap.gd")
var plyr_play_map = PLYR_PLY_MAP.new()

const PSIDE_ROOM_CLASS = preload("res://Assets/SystemScripts/PSideRoom.gd")

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
	plyr_play_map.set_map_grid(map_grid)
	
	for x in range(map_data.size()):
		for z in range(map_data[0].size()):
			for obj in range(map_data[x][z].size()):
				var object = map_data[x][z][obj][0]
				
				match object['Identifier']:
					'BaseGround': 
						var ground = GlobalVars.obj_spawner.spawn_map_object(object['Identifier'], plyr_play_map, [x,z], false)
						ground.set_id(object)
						ground.set_parent_map(plyr_play_map)
						map_grid[x][z].append(ground)
					'BaseWall': 
						var wall = GlobalVars.plyr_obj_spawner.spawn_map_object(object['Identifier'], plyr_play_map, [x,z], false)
						wall.set_id(object)
						wall.set_parent_map(plyr_play_map)
						map_grid[x][z].append(wall)
					'BaseStairs':
						var stairs = GlobalVars.plyr_obj_spawner.spawn_map_object(object['Identifier'], plyr_play_map, [x,z], false)
						stairs.set_id(object)
						stairs.set_parent_map(plyr_play_map)
						map_grid[x][z].append(stairs)
					'PlagueDoc': 
						if object['NetID'] == GlobalVars.self_netID:
							var client_player = GlobalVars.plyr_obj_spawner.spawn_actor('PSidePlayer', plyr_play_map, [x,z], false)
							Server.add_player_to_local_player_list(client_player)
							client_player.update_id('NetID', GlobalVars.self_netID)
							client_player.update_id('Instance ID', object['Instance ID'])
							client_player.set_map_pos(client_player.get_id()['Position'])
							map_grid[x][z].append(client_player)
							
							GlobalVars.self_instanceObj = client_player
						else:
							var other_player = GlobalVars.plyr_obj_spawner.spawn_actor(object['Identifier'], plyr_play_map, [x,z], false)
							Server.add_player_to_local_player_list(other_player)
							other_player.update_id('NetID', object['NetID'])
							other_player.update_id('Instance ID', object['Instance ID'])
							map_grid[x][z].append(other_player)
					'Fox':
						var fox = GlobalVars.plyr_obj_spawner.spawn_actor(object['Identifier'], plyr_play_map, [x,z], false)
						fox.set_id(object)
						fox.set_parent_map(plyr_play_map)
						map_grid[x][z].append(fox)
					'Imp':
						var imp = GlobalVars.plyr_obj_spawner.spawn_actor(object['Identifier'], plyr_play_map, [x,z], false)
						imp.set_id(object)
						imp.set_parent_map(plyr_play_map)
						map_grid[x][z].append(imp)
	
	plyr_play_map.set_map_grid(map_grid)
	
	# Unpack room data.
	var map_rooms = GlobalVars.server_map_data[2]
	for room in map_rooms:
		var curr_room = PSIDE_ROOM_CLASS.new()
		
		curr_room.parent_map = plyr_play_map
		curr_room.parent_id = plyr_play_map.get_map_server_id()
		curr_room.id = room.id
		curr_room.type = room.type
		
		curr_room.split = room.split
		curr_room.center = room.center
		
		curr_room.x = room.x
		curr_room.z = room.z
		curr_room.w = room.w
		curr_room.l = room.l
		curr_room.area = room.area
		
		curr_room.topleft = room.topleft
		curr_room.topright = room.topright
		curr_room.bottomleft = room.bottomleft
		curr_room.bottomright = room.bottomright
		
		curr_room.enemy_count = room.enemy_count
		curr_room.exits = room.exits
		curr_room.distance_to_spawn = room.distance_to_spawn
		
		plyr_play_map.rooms.append(curr_room)
	
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
