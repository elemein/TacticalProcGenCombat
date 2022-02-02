extends Node

const MAPSET_CLASS = preload("res://Assets/SystemScripts/Mapset.gd")

var network = NetworkedMultiplayerENet.new()
var network_api = MultiplayerAPI.new()

var world = Node.new()

var port = 7369
var max_players = 32

var players_dict = {}

func _ready():
	self.name = 'Server'
	create_server()

func _process(delta):
	if custom_multiplayer.has_network_peer() == false: return
	custom_multiplayer.poll()

func create_server():
	create_world()
	network.create_server(port, max_players)
	set_custom_multiplayer(network_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	print("Server started.")
	
	network.connect("peer_connected", self, "_player_connected")
	network.connect("peer_disconnected", self, "_player_disconnected")

func create_world():
	world.name = 'World'
	add_child(world)
	
	var dungeon = MAPSET_CLASS.new('The Cave', 3)
	
	world.add_child(dungeon)


func _player_connected(id):
	print('Player ' + str(id) + ' has connected!')

	var spawn_to_map = world.get_node("The Cave").floors['Dungeon Floor 1']
	var spawn_to_pos = spawn_to_map.get_map_start_tile()
	
	var new_player = GlobalVars.obj_spawner.spawn_dumb_actor('PlagueDoc', spawn_to_map, spawn_to_pos, true)

	new_player.update_id('NetID', id)
	players_dict[id] = new_player
	new_player.name = 'Player%d' % new_player.get_id()['NetID']
	new_player.play_anim('idle')
	
func _player_disconnected(id):
	print('Goodbye player ' + str(id) + '.')

# Send id to client.
remote func send_id_to_requester():
	var player_id = custom_multiplayer.get_rpc_sender_id()
	rpc_id(player_id, "receive_id_from_server", player_id)

func move_to_map(object, map):
	map.add_map_object(object, map.get_map_start_tile())
	
	map.print_map_grid()
	
	object.view_finder.clear_vision()
	self.resolve_all_viewfields(map)
	
	self.move_client_to_map(object, map)
	
	self.object_action_event(object.get_id(), {"Command Type": "Spawn On Map"})

func move_client_to_map(client_obj, map):
	rpc_id(client_obj.get_id()['NetID'], 'prepare_for_map_change', map.get_map_server_id())

# Server handles query for action.
remote func query_for_action(requester, request):
	var player_id = requester
	var player_obj = players_dict[custom_multiplayer.get_rpc_sender_id()]
	var player_identity = player_obj.get_id()
	var player_turn_timer = player_obj.get_parent_map().get_turn_timer()

	match request['Command Type']:
		'Look':
			if player_turn_timer.get_time_left() == 0:
				self.object_action_event(player_identity, request)
			else: print('Discarding illegal look request from ' + str(player_id))
		
		'Move':
			if player_turn_timer.get_time_left() == 0:
				var move_action = "move %s" % [request['Value']]
				player_obj.set_action(move_action)
				send_action_request_confirm(player_obj.get_id(), {"Condition": "Allow", "Option": "Move", "SubOption": move_action})
			else: print('Discarding illegal move request from ' + str(player_id))
				
		'Basic Attack':
			if player_turn_timer.get_time_left() == 0:
				player_obj.set_action("basic attack")
				send_action_request_confirm(player_obj.get_id(), {"Condition": "Allow", "Option": "Basic Attack"})
			else: print('Discarding illegal basic attack request from ' + str(player_id))
		
		'Idle':
			if player_turn_timer.get_time_left() == 0:
				player_obj.set_action("idle")
			else: print('Discarding illegal idle request from ' + str(player_id))

		'Fireball':
			if (player_turn_timer.get_time_left() == 0):
				if (player_obj.get_mp() > player_obj.find_node("Fireball").spell_cost):
					player_obj.set_action("fireball")
					send_action_request_confirm(player_obj.get_id(), {"Condition": "Allow", "Option": "Fireball"})
				else: 
					send_action_request_confirm(player_obj.get_id(), {"Condition": "Deny", "Option": "Play OOM"})
			else: print('Discarding illegal fireball request from ' + str(player_id))

		'Dash':
			if (player_turn_timer.get_time_left() == 0):
				if (player_obj.get_mp() > player_obj.find_node("Dash").spell_cost):
					player_obj.set_action("dash")
					send_action_request_confirm(player_obj.get_id(), {"Condition": "Allow", "Option": "Dash"})
				else: 
					send_action_request_confirm(player_obj.get_id(), {"Condition": "Deny", "Option": "Play OOM"})
			else: print('Discarding illegal dash request from ' + str(player_id))

		'Self Heal':
			if (player_turn_timer.get_time_left() == 0):
				if (player_obj.get_mp() > player_obj.find_node("SelfHeal").spell_cost):
					player_obj.set_action("self heal")
					send_action_request_confirm(player_obj.get_id(), {"Condition": "Allow", "Option": "Self Heal"})
				else: 
					send_action_request_confirm(player_obj.get_id(), {"Condition": "Deny", "Option": "Play OOM"})
			else: print('Discarding illegal heal request from ' + str(player_id))
			
		'Drop Item':
			if (player_turn_timer.get_time_left() == 0):
				player_obj.selected_item = instance_from_id(request['Value'])
				player_obj.set_action('drop item')
				send_action_request_confirm(player_obj.get_id(), {"Condition": "Allow", "Option": "Drop Item"})
			else: print('Discarding drop item request from ' + str(player_id))
		'Equip Item':
			if (player_turn_timer.get_time_left() == 0):
				player_obj.selected_item = instance_from_id(request['Value'])
				player_obj.set_action('equip item')
				send_action_request_confirm(player_obj.get_id(), {"Condition": "Allow", "Option": "Equip Item"})
			else: print('Discarding equip item request from ' + str(player_id))
		'Unequip Item':
			if (player_turn_timer.get_time_left() == 0):
				player_obj.selected_item = instance_from_id(request['Value'])
				player_obj.set_action('unequip item')
				send_action_request_confirm(player_obj.get_id(), {"Condition": "Allow", "Option": "Unequip Item"})
			else: print('Discarding unequip item request from ' + str(player_id))

func map_object_event(map_id, map_action):
	for player in players_dict.values():
		if map_id == player.get_id()['Map ID']:
			rpc_id(player.get_id()['NetID'], 'receive_map_object_event', map_id, map_action)

	receive_map_object_event(map_id, map_action)

remote func receive_map_object_event(map_id, map_action):
	print([map_id, map_action])
	match map_action['Scope']:
		"Room":
			var room
			for map in world.get_node('The Cave').floors.values():
				if map_id == map.get_map_server_id():
					for each_room in map.rooms:
						if each_room.id == map_action['Room ID']:
							room = each_room
			
			match map_action['Action']:
				'Block Exits':
					room.block_exits()
				'Unblock Exits':
					room.unblock_exits()

# Duplicate the object's resources to send out, and prompt all clients to receive command.
func object_action_event(object_id, action):
	var object = get_object_from_identity(object_id)
	if object == null and action['Command Type'] != 'Spawn On Map': return

	print("SERVER: %s(%s) does: %s" % [object_id['Identifier'], object_id['Instance ID'], action])
	
	# determine action
	match action['Command Type']:
		'Look':
			object.set_direction(action['Value'])
			object.update_id('Facing', action['Value'])
		'Move':
			object.set_direction(action['Value'])
			object.update_id('Facing', action['Value'])
			object.move_actor_in_facing_dir(1)
			object.update_id('Position', object.get_map_pos())
		'Idle':
			pass
		'Basic Attack':
			object.set_direction(action['Value'])
			object.update_id('Facing', action['Value'])
			object.perform_action(action)
		'Fireball':
			object.perform_action(action)
		'Dash':
			object.perform_action(action)
			object.update_id('Position', object.get_map_pos())
		'Self Heal':
			object.perform_action(action)
		'Die':
			object.die()
		'Remove From Map':
			var map = get_map_from_map_id(object.get_id()['Map ID'])
			map.remove_map_object(object)
			if GlobalVars.get_self_netid() != 1:
				if object.get_id()['Identifier'] == 'PlagueDoc':
					self.player_list.erase(object)
		'Spawn On Map': # Only for client. Server must spawn objects directly.
			if GlobalVars.peer_type == 'client':
				if object_id['Instance ID'] != GlobalVars.get_self_instance_id():
					spawn_object_in_map(object_id)
					
	
	for player in players_dict.values():
		if object_id['Map ID'] == player.get_id()['Map ID']:
			rpc_id(player.get_id()['NetID'], 'receive_object_action_event', object_id, action)

func send_action_request_confirm(actor_id, response):
	rpc_id(actor_id['NetID'], "receive_action_request_confirm", actor_id, response)

# Send map to requester.
remote func send_map_to_requester():
	var player_id = custom_multiplayer.get_rpc_sender_id()
	
	var map = players_dict[player_id].get_parent_map()
	var map_id = map.get_map_server_id()
	var map_data = map.return_map_grid_encoded_to_string()
	var map_rooms = map.return_rooms_encoded_to_dict()
	var parent_mapset_name = map.get_parent_mapset().get_mapset_name()
	var map_name = map.get_map_name()
	var map_dict = {"Parent Mapset Name": parent_mapset_name, \
					"Map Name": map_name, "Map ID": map_id, \
					"Grid Data": map_data, "Room Data": map_rooms}
	
	print(map_data)
	print("Sending map data to requester.")
	rpc_id(player_id, 'receive_map_from_server', map_dict)

func resolve_all_viewfields(map):
	for player in players_dict.values():
		if map.get_map_server_id() == player.get_id()['Map ID']:
			rpc_id(player.get_id()['NetID'], 'resolve_viewfield')

func update_all_actor_stats(object: ActorObj):
	var object_id = object.get_id()
	for player in players_dict.values():
		if object_id['Map ID'] == player.get_id()['Map ID']:
			if player.get_id()['NetID'] != 1:
				rpc_id(player.get_id()['NetID'], 'receive_update_all_actor_stats', object_id, object.stat_dict, object.ready_status)
			

func get_object_from_identity(object_id):
	var map
	
	for child_map in world.get_node('The Cave').floors.values():
		if child_map.get_map_server_id() == object_id['Map ID']: map = child_map

	# determine object
	var object
	match object_id['Category']:
		'Actor':
			for obj in map.get_node("Enemies").get_children():
				if obj.get_id()['Instance ID'] == object_id['Instance ID']: object = obj
			for obj in map.get_node("Players").get_children():
				if obj.get_id()['Instance ID'] == object_id['Instance ID']: object = obj
		
		'Inv Item':
			for obj in map.get_node("Objects").get_children():
				if obj.get_id()['Instance ID'] == object_id['Instance ID']: object = obj

	return object

func get_map_from_map_id(mapid):
	var map
	for flr in world.get_node('The Cave').floors.values():
		if mapid == flr.get_map_server_id(): map = flr
	return map

func update_round_for_players_in_map(map):
	var map_id = map.get_map_server_id()
	for player in players_dict.values():
		if player.get_id()['Map ID'] == map_id: rpc_id(player.get_id()['NetID'], 'receive_round_update')

remote func spawn_object_in_map(object_id):
	var x = object_id['Position'][0]
	var z = object_id['Position'][1]
	
	match object_id['Identifier']:
		'PlagueDoc': 
			var player = GlobalVars.obj_spawner.spawn_dumb_actor(object_id['Identifier'], MultiplayerTestenv.get_client().get_client_obj().get_parent_map(), [x,z], false)
			player.set_id(object_id)
			player.play_anim('idle')
			self.player_list.append(player)

		'Spike Trap':
			var trap = GlobalVars.obj_spawner.spawn_map_object(object_id['Identifier'], MultiplayerTestenv.get_client().get_client_obj().get_parent_map(), [x,z], false)
			trap.set_id(object_id)
		
		'Coins':
			var obj = GlobalVars.obj_spawner.spawn_gold(object_id['Gold Value'], get_map_from_map_id(object_id['Map ID']), object_id['Position'], true)
			obj.set_id(object_id)
	
	match object_id['Category']:
		'Inv Item':
			var obj = GlobalVars.obj_spawner.spawn_item(object_id['Identifier'], get_map_from_map_id(object_id['Map ID']), object_id['Position'], true)
			obj.set_id(object_id)


remote func send_inventory_to_requester(requester_identity):
	var inventory_owner = get_object_from_identity(requester_identity)
	var inventory = inventory_owner.inventory

	rpc_id(requester_identity['NetID'], "receive_inventory_from_server", inventory)
