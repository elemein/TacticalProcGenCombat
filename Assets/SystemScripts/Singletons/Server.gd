extends Node

var peer = NetworkedMultiplayerENet.new()
var port = 7369
var max_players = 32

var player_list = []

func create_server():
	GlobalVars.peer_type = 'server'
	peer.create_server(port, max_players)
	get_tree().network_peer = peer
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	print("Server opened successfully on port " + str(port))
	player_list.append(GlobalVars.server_player)
	GlobalVars.self_netID = 1

func identity_update(updated_identity):
	# THIS SHOULD BE REMOVED, AS ACTUAL ACTION COMMANDS THEMSELVES SHOULD UPDATE IDENTITY
	rpc('receive_identity_update', updated_identity)
	receive_identity_update(updated_identity)

func object_action_event(object_id, action):
	var orig_object_id = object_id.duplicate(true)
	var orig_action = action.duplicate(true)
	
	rpc('receive_object_action_event', orig_object_id, orig_action)
	receive_object_action_event(orig_object_id, orig_action)

func resolve_all_viewfields():
	resolve_viewfield()
	rpc('resolve_viewfield')

remote func resolve_viewfield():
	GlobalVars.self_instanceObj.find_viewfield()
	GlobalVars.self_instanceObj.resolve_viewfield_to_screen()

remote func receive_object_action_event(object_id, action):
	# determine map
	var map
	for child_map in GlobalVars.total_mapsets:
		if child_map.get_map_server_id() == object_id['Map ID']: map = child_map
	
	# determine object
	var object
	var x = object_id['Position'][0]
	var z = object_id['Position'][1]
	var tile_objs = map.get_tile_contents(x, z)

	for obj in tile_objs:
		if obj.get_id()['Instance ID'] == object_id['Instance ID']:
			object = obj
	
	print("%s(%s) does: %s" % [object_id['Identifier'], object_id['Instance ID'], action])
	
	# determine action
	match action['Command Type']:
		'Look':
			object.set_direction(action['Value'])
			object.update_id('Facing', action['Value'])
		'Move':
			object.set_direction(action['Value'])
			object.move_actor_in_facing_dir(1)
			object.update_id('Position', object.get_map_pos())

# SERVER SIDE COMMANDS FUNCS
remote func send_map_to_requester(requester):
	var player_id = get_tree().get_rpc_sender_id()
	var map_data = PlayerInfo.current_map.return_map_grid_encoded_to_string()
	var map_id = PlayerInfo.current_map.get_map_server_id()
	print(map_data)
	print("Sending map data to requester.")
	rpc_id(player_id, 'receive_map_from_server', map_id, map_data)

remote func query_for_action(requester, request):
	var player_id = requester
	var player_obj
	var player_identity
	var player_map
	var player_turn_timer
	
	for player in player_list:
		if player.get_id()['NetID'] == player_id:
			player_obj = player
			player_identity = player.get_id()
			player_map = player.get_parent_map()
			player_turn_timer = player.get_parent_map().get_turn_timer()
	
	match request['Command Type']:
		'Look':
			if player_turn_timer.get_time_left() == 0:
				Server.object_action_event(player_identity, request)
			else:
				print('Discarding illegal look request from ' + str(player_id))
		
		'Move':
			if player_turn_timer.get_time_left() == 0:
				player_obj.set_action("move %s" % [request['Value']])
			else:
				print('Discarding illegal move request from ' + str(player_id))

# SERVER SIDE SIGNAL FUNCS ----------------------
func _player_connected(id):
	print('Player ' + str(id) + ' has connected!')
	
	var spawn_to_map = GlobalVars.server_player.get_parent_map()
	var spawn_to_pos = GlobalVars.server_player.get_map_pos().duplicate()
	spawn_to_pos[1] += 1
	
	var new_player = GlobalVars.obj_spawner.spawn_actor('PlagueDoc', spawn_to_map, spawn_to_pos, true)
	new_player.update_id('NetID', id)
	player_list.append(new_player)
	
	new_player.get_parent_map().get_turn_timer().add_to_timer_group(new_player)
	
	var instance_id = new_player.get_id()['Instance ID']
	
	rpc_id(id, "receive_id_from_server", id, instance_id)

func _player_disconnected(id):
	print('Goodbye player ' + str(id) + '.')
	for player in player_list:
		if player.get_id()['NetID'] == id:
			player.get_parent_map().remove_map_object(player)
			player_list.erase(player)
			player.get_parent_map().get_turn_timer().remove_from_timer_group(player)

# CLIENT SIDE FUNCS ------------------------------
func request_map_from_server():
	print("Requesting map from server.")
	rpc_id(1, "send_map_to_requester", get_instance_id())

func request_for_player_action(request):
	if GlobalVars.self_netID == 1:
		query_for_action(GlobalVars.self_netID, request)
	else:	
		rpc_id(1, "query_for_action", GlobalVars.self_netID, request)

remote func receive_map_from_server(map_id, map_data):
	GlobalVars.server_map_data = [map_id, map_data]

remote func receive_id_from_server(net_id, instance_id):
	GlobalVars.self_netID = net_id
	GlobalVars.self_instanceID = instance_id

remote func receive_identity_update(updated_identity):
	var old_identity
	var player_obj
	
	for player in player_list:
		if player.get_id()['NetID'] == updated_identity['NetID']:
			player_obj = player
			old_identity = player.get_id()
	
	player_obj.set_id(updated_identity)

# SERVER UTILITY FUNCTIONS ---
func add_player_to_local_player_list(player):
	player_list.append(player)

func get_player_obj_from_netid(netid):
	for player in player_list:
		if player.get_id()['NetID'] == netid:
			return player
