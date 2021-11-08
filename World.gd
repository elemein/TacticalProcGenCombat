extends Node

var map_name = 'The Cave'

const MAPSET_CLASS = preload("res://Assets/SystemScripts/Mapset.gd")
var dungeon = MAPSET_CLASS.new(map_name, 3)

var mapsets = []

func _ready():
	GlobalVars.set_self_netID(1)
	catalog_dungeon_to_server()
	create_server_player_and_spawn_to_map()

	MultiplayerTestenv.get_client().get_client_obj().name = 'Player1'

	CommBus.create_server()

	Signals.emit_signal("world_loaded")
	MultiplayerTestenv.get_client().set_client_state('ingame')

func create_server_player_and_spawn_to_map():
	var first_floor
	for mapset in GlobalVars.total_mapsets:
		if mapset.dungeon_name == 'The Cave':
			first_floor = mapset.floors['Dungeon Floor 1']
	
	var first_floor_start_tile = first_floor.get_map_start_tile()
	
	var server_player = GlobalVars.obj_spawner.spawn_dumb_actor('PlagueDoc', \
						first_floor, first_floor_start_tile, true)
	
	GlobalVars.set_self_obj(server_player)
	
	CommBus.player_list.append(MultiplayerTestenv.get_client().get_client_obj())
	
	MultiplayerTestenv.get_client().get_client_obj().find_and_render_viewfield()

func catalog_dungeon_to_server():
	add_child(dungeon)
	mapsets = [dungeon]
	
	for mapset in mapsets:
		GlobalVars.total_mapsets.append(mapset)
		for level in mapset.floors:
			GlobalVars.total_maps.append(mapset.floors[level])

func move_to_map(object, map):
	map.add_map_object(object, map.get_map_start_tile())
	
	map.print_map_grid()
	
	object.view_finder.clear_vision()
	CommBus.resolve_all_viewfields(map)
	
	if object.get_id()['NetID'] != 1:
		CommBus.move_client_to_map(object, map)
	
	CommBus.object_action_event(object.get_id(), {"Command Type": "Spawn On Map"})
