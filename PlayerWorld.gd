extends Node

onready var blank_node = preload("res://Assets/SystemScripts/blank_node.tscn")

const MAPSET = preload("res://Assets/SystemScripts/Mapset.gd")
var map_set = MAPSET.new(null, null)

const PLYR_PLY_MAP = preload("res://Assets/SystemScripts/PlayerPlayMap.gd")
var plyr_play_map = PLYR_PLY_MAP.new()

const PSIDE_ROOM_CLASS = preload("res://Assets/SystemScripts/PSideRoom.gd")

var mapsets = []
var floor_num = 0

func _ready():
	catalog_dungeon_to_server()
	unpack_map(GlobalVars.server_map_data)
	
	GlobalVars.self_instanceObj.find_and_render_viewfield()
	Signals.emit_signal("world_loaded")

func catalog_dungeon_to_server():
	plyr_play_map.name = GlobalVars.server_map_name
	add_child(plyr_play_map)
	mapsets = [plyr_play_map]
	GlobalVars.total_maps.append(plyr_play_map)

func clear_play_map():
	for child in plyr_play_map.get_children():
		plyr_play_map.remove_child(child)
		
		if not child.get('object_identity') == null and child.get_id()['Identifier'] == 'PlagueDoc':
			Server.player_list.erase(child)
			
		child.queue_free()

func unpack_map(map_data):
	floor_num += 1
	plyr_play_map.set_map_server_id(map_data[0])
	map_data = map_data[1]
	var map_grid = []
	
	Server.player_list = []
	
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
				var new_object = null
				
				match object['Identifier']:
					'BaseGround': 
						new_object = GlobalVars.obj_spawner.spawn_map_object(object['Identifier'], plyr_play_map, [x,z], false)
						new_object.translation.y = 0 # on server, these are spawned at 0
					'BaseWall': 
						new_object = GlobalVars.obj_spawner.spawn_map_object(object['Identifier'], plyr_play_map, [x,z], false)
						new_object.translation.y = 0 # on server, these are spawned at 0
					'BaseStairs':
						new_object = GlobalVars.obj_spawner.spawn_map_object(object['Identifier'], plyr_play_map, [x,z], false)
					'PlagueDoc': 
						if object['NetID'] == GlobalVars.self_netID:
							new_object = GlobalVars.obj_spawner.spawn_actor('Player', plyr_play_map, [x,z], false)
						else:
							new_object = GlobalVars.obj_spawner.spawn_actor(object['Identifier'], plyr_play_map, [x,z], false)
						
						Server.add_player_to_local_player_list(new_object)
						new_object.update_id('NetID', object['NetID'])
						new_object.update_id('Instance ID', object['Instance ID'])
						new_object.play_anim('idle')
						
						if not new_object in Server.player_list:
							Server.player_list.append(new_object)
						
						if object['NetID'] == GlobalVars.self_netID:
							GlobalVars.self_instanceObj = new_object
							GlobalVars.self_instanceObj.connect_to_status_bars()
							
					_:
						match object['CategoryType']:
							'Enemy':
								new_object = GlobalVars.obj_spawner.spawn_actor(object['Identifier'], plyr_play_map, [x,z], false)
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
	
	# Organize Nodes
	var floor_node = blank_node.instance()
	plyr_play_map.add_child(floor_node)
	floor_node.name = 'Floor%d' % [floor_num]
	for child in plyr_play_map.get_children():
		if not 'Floor' in child.name:
			plyr_play_map.remove_child(child)
			floor_node.add_child(child)
	var map_dict = {'Dungeon Floor %d' % [floor_num]: floor_node}
	map_set.organize_map_nodes(map_dict, floor_num)
	
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
	for player in Server.player_list:
		if player.object_identity['NetID'] == GlobalVars.self_netID:
			GlobalVars.self_instanceObj = player
	
	Server.notify_server_map_loaded(plyr_play_map.get_map_server_id())
