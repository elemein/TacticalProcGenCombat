extends Node

const PLYR_PLY_MAP = preload("res://Assets/SystemScripts/C_Map.gd")
var plyr_play_map = PLYR_PLY_MAP.new()

const PSIDE_ROOM_CLASS = preload("res://Assets/SystemScripts/PSideRoom.gd")

var map_data

func catalog_dungeon_to_server():
	plyr_play_map.name = map_data['Map Name']
	
	GlobalVars.total_maps.append(plyr_play_map)

func unpack_map(data):
	map_data = data
	
	catalog_dungeon_to_server()
	var map_to_return = fill_map()

	return map_to_return

func fill_map():
	plyr_play_map.set_map_server_id(map_data['Map ID'])
	plyr_play_map.map_name = map_data['Map Name']
	map_data = map_data['Grid Data']
	var map_grid = []
	
	Server.player_list = []

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
				var new_object = null
				
				match object['Identifier']:
					'BaseGround', 'BaseWall', 'BaseStairs', 'TempWall': 
						new_object = GlobalVars.obj_spawner.spawn_map_object(object['Identifier'], plyr_play_map, [x,z], false)

					'PlagueDoc': 
						if object['NetID'] == GlobalVars.get_self_netid():
							new_object = GlobalVars.obj_spawner.spawn_dumb_actor('PlagueDoc', plyr_play_map, [x,z], false)
							GlobalVars.set_self_obj(new_object)
						else:
							new_object = GlobalVars.obj_spawner.spawn_dumb_actor(object['Identifier'], plyr_play_map, [x,z], false)
						
						new_object.play_anim('idle')
						Server.add_player_to_local_player_list(new_object)
						
						if not new_object in Server.player_list:
							Server.player_list.append(new_object)
						
					_:
						match object['CategoryType']:
							'Enemy':
								new_object = GlobalVars.obj_spawner.spawn_dumb_actor(object['Identifier'], plyr_play_map, [x,z], false)
							'Weapon', 'Accessory', 'Armour':
								new_object = GlobalVars.obj_spawner.spawn_item(object['Identifier'], plyr_play_map, [x,z], false)
							'Coins':
								new_object = GlobalVars.obj_spawner.spawn_gold(object['Gold Value'], plyr_play_map, [x,z], false)
							'Trap':
								pass
							_:
								pass
				if new_object != null:
					new_object.set_id(object)
	
	plyr_play_map.set_map_grid(map_grid)
	
	# Unpack room data.
	var map_rooms = GlobalVars.server_map_data["Room Data"]
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
	
	return plyr_play_map