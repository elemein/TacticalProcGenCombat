extends Node

var peer = NetworkedMultiplayerENet.new()
var port = 7369
var max_players = 32

var player_list = []

var sync_queue = []

func create_server():
	GlobalVars.peer_type = 'server'
	peer.create_server(port, max_players)
	get_tree().network_peer = peer
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	print("Server opened successfully on port " + str(port))
	player_list.append(GlobalVars.self_obj)
	GlobalVars.self_netID = 1

# How turns work, from input:
# Input (for ex. basic attack)
# Input > request_for_player_action(request)
# Request goes to server > query_for_action(requester, request)
# Server checks if that move is allowed. If so: > requester.set_action(action)
# THEN
# TurnTimer goes to > process_turn() when all actors are ready.
# actor.process_turn() > object_action_event(object_id, action) 
# object_action_event(object_id, action) > actor.perform_action(action) > 
# receive_object_action_event(object_id, action)
# Parse through what the action was and who did it
# actor.set_direction & object.update_id('Facing', action['Value']), if required
# object.perform_action(action) > actor.emit_signal(spell_cast_basic_attack)
# actor's appropriate action then happens, with most code run by server and
# client, but some is only serverside, such as changing stats and issuing notifs.

# OBJECT ACTION COMMANDS ------------------------------
# Query server for permission to perform action.
func request_for_player_action(request):
	if GlobalVars.self_netID == 1:
		query_for_action(GlobalVars.self_netID, request)
	else:	
		rpc_id(1, "query_for_action", GlobalVars.self_netID, request)
# Server handles query for action.
remote func query_for_action(requester, request):
	var player_id = requester
	var player_obj : ActorObj
	var player_identity
	var player_turn_timer
	
	for player in player_list:
		if player.get_id()['NetID'] == player_id:
			player_obj = player
			player_identity = player.get_id()
			player_turn_timer = player.get_parent_map().get_turn_timer()
	
	match request['Command Type']:
		'Look':
			if player_turn_timer.get_time_left() == 0:
				Server.object_action_event(player_identity, request)
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

func send_action_request_confirm(actor_id, response):
	if actor_id['NetID'] == 1:
		receive_action_request_confirm(actor_id, response)
	else:
		rpc_id(actor_id['NetID'], "receive_action_request_confirm", actor_id, response)

remote func receive_action_request_confirm(actor_id, response):
	if GlobalVars.client_state != 'ingame': # If the client is loading, we don't want to change the map being loaded.
		sync_queue.push_back({"Event Type": "Action Confirm", "Actor Id": actor_id, "Response": response})
		return
	var gui = get_node("/root/World/GUI/Action")
	var player_obj = get_player_obj_from_netid(actor_id['NetID'])
	
	match response["Condition"]:
		'Allow':
			match response["Option"]:
				"Basic Attack":gui.set_action('basic attack')
				"Move":
					match response["SubOption"]:
						'move up': gui.set_action('move up')
						'move down': gui.set_action('move down')
						'move left': gui.set_action('move left')
						'move right': gui.set_action('move right')
						
						'move upleft': gui.set_action('move upleft')
						'move upright': gui.set_action('move upright')
						'move downleft': gui.set_action('move downleft')
						'move downright': gui.set_action('move downright')
						
				"Drop Item": gui.set_action('drop item')
				"Equip Item": gui.set_action('equip item')
				"Unequip Item": gui.set_action('unequip item') 
				"Fireball": gui.set_action('fireball')
				"Dash": gui.set_action('dash')
				"Self Heal": gui.set_action('self heal')
		
		'Deny':
			match response["Option"]:
				"Play OOM": player_obj.find_node("SelfHeal").out_of_mana.play()

# Duplicate the object's resources to send out, and prompt all clients to receive command.
func object_action_event(object_id, action):
	var orig_object_id = object_id.duplicate(true)
	var orig_action = action.duplicate(true)
	
	for player in player_list:
		if object_id['Map ID'] == player.get_id()['Map ID']:
			if player.get_id()['NetID'] != 1:
				rpc_id(player.get_id()['NetID'], 'receive_object_action_event', orig_object_id, orig_action)
	
	receive_object_action_event(orig_object_id, orig_action)
# Parse action of object and run required actions to perform action.
remote func receive_object_action_event(object_id, action):
	if GlobalVars.client_state != 'ingame': # If the client is loading, we don't want to change the map being loaded.
		sync_queue.push_back({"Event Type": "Action", "ObjectID": object_id, "Action": action})
		return
	
	var object = get_object_from_identity(object_id)

	if object == null and action['Command Type'] != 'Spawn On Map': return

	print("%s(%s) does: %s" % [object_id['Identifier'], object_id['Instance ID'], action])
	
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
			if GlobalVars.self_netID != 1:
				if object.get_id()['Identifier'] == 'PlagueDoc':
					self.player_list.erase(object)
		'Spawn On Map': # Only for client. Server must spawn objects directly.
			if GlobalVars.peer_type == 'client':
				if object_id['Instance ID'] != GlobalVars.self_instanceID:
					spawn_object_in_map(object_id)
			
# -----------------------------------------------------

func update_round_for_players_in_map(map):
	var map_id = map.get_map_server_id()
	for player in player_list:
		if player.get_id()['Map ID'] == map_id:
			if player.get_id()['NetID'] == 1:
				receive_round_update()
			else:
				rpc_id(player.get_id()['NetID'], 'receive_round_update')

remote func receive_round_update():
	if GlobalVars.client_state != 'ingame': # If the client is loading, we don't want to change the map being loaded.
		return
	var gui = get_node("/root/World/GUI/Action")
	gui.clear_action()

func request_for_inventory():
	if GlobalVars.self_netID == 1:
		send_inventory_to_requester(GlobalVars.self_obj.get_id())
	else:	
		rpc_id(1, "send_inventory_to_requester", GlobalVars.self_obj.get_id())

remote func send_inventory_to_requester(requester_id):
	var inventory_owner = instance_from_id(requester_id['Instance ID'])
	var inventory = inventory_owner.inventory

	if requester_id['NetID'] == 1:
		receive_inventory_from_server(inventory)
	else:	
		rpc_id(requester_id['NetID'], "receive_inventory_from_server", inventory)

remote func receive_inventory_from_server(inventory):
	if not GlobalVars.client_state != 'ingame': # If the client is loading, we don't want to change the map being loaded.
		GlobalVars.self_obj.build_inv_from_server(inventory)
	
# CHANGING STAT COMMANDS -------------------------------
# This is a duplicate from below. More bandwidth but easier to maintain
func update_all_actor_stats(object: ActorObj):
	var object_id = object.get_id()
	for player in player_list:
		if object_id['Map ID'] == player.get_id()['Map ID']:
			if player.get_id()['NetID'] != 1:
				rpc_id(player.get_id()['NetID'], 'receive_update_all_actor_stats', object_id, object.stat_dict, object.ready_status)
			
remote func receive_update_all_actor_stats(object_id, new_stat_dict, ready_status):
	if not GlobalVars.client_state != 'ingame':
		var object = get_object_from_identity(object_id)
		
		if object == null: return
		
		object.stat_dict = new_stat_dict
		object.ready_status = ready_status

# CHANGING STAT COMMANDS -------------------------------
# Prompt to all clients to change a given actor's stat.
func update_actor_stat(object_id, stat_update):
	for player in player_list:
		if object_id['Map ID'] == player.get_id()['Map ID']:
			if player.get_id()['NetID'] != 1:
				rpc_id(player.get_id()['NetID'], 'receive_actor_stat_update', object_id, stat_update)
	
	receive_actor_stat_update(object_id, stat_update)
# Find the stat and adjust it.
remote func receive_actor_stat_update(object_id, stat_update):
	if GlobalVars.client_state != 'ingame': # If the client is loading, we don't want to change the map being loaded.
		sync_queue.push_back({"Event Type": "Stat Update", "ObjectID": object_id, "Update": stat_update})
		return
	if object_id['Map ID'] != 0:
		var object = get_object_from_identity(object_id)
		
		match stat_update['Stat']:
			'HP':
				object.set_hp(object_id['HP'] + stat_update['Modifier'])
			'MP':
				object.set_mp(object_id['MP'] + stat_update['Modifier'])
# ------------------------------------------------------

# NOTIF COMMANDS ---------------------------------------
# Prompt to all clients to display a notif.
func actor_notif_event(object_id, notif_text, notif_type):
	for player in player_list:
		if object_id['Map ID'] == player.get_id()['Map ID']:
			if player.get_id()['NetID'] != 1:
				rpc_id(player.get_id()['NetID'], 'receive_actor_notif_event', object_id, notif_text, notif_type)	

	receive_actor_notif_event(object_id, notif_text, notif_type)
# Get the object and display the notif.
remote func receive_actor_notif_event(object_id, notif_text, notif_type):
	if GlobalVars.client_state != 'ingame': # If the client is loading, we don't want to change the map being loaded.
		sync_queue.push_back({"Event Type": "Notification", "ObjectID": object_id, "Notif Text": notif_text, "Notif Type": notif_type})
		return

	var object = get_object_from_identity(object_id)
	object.display_notif(notif_text, notif_type)
# -----------------------------------------------------

# VISION RELATED COMMANDS ------------------------------
# Prompt to get everyone to review their vision.
func resolve_all_viewfields(map):
	for player in player_list:
		if map.get_map_server_id() == player.get_id()['Map ID']:
			if player.get_id()['NetID'] != 1:
				rpc_id(player.get_id()['NetID'], 'resolve_viewfield')
	
	resolve_viewfield()
# Resolve your viewfield and render it to screen.
remote func resolve_viewfield():
	if GlobalVars.get_client_state() == 'ingame':
		GlobalVars.self_obj.find_viewfield()
		GlobalVars.self_obj.resolve_viewfield_to_screen()
# ------------------------------------------------------

# MAP ACTION COMMANDS ---------------------------------
#
func map_object_event(map_id, map_action):
	for player in player_list:
		if map_id == player.get_id()['Map ID']:
			if player.get_id()['NetID'] != 1:
				rpc_id(player.get_id()['NetID'], 'receive_map_object_event', map_id, map_action)

	receive_map_object_event(map_id, map_action)
#
remote func receive_map_object_event(map_id, map_action):
	if GlobalVars.client_state != 'ingame': # If the client is loading, we don't want to change the map being loaded.
		sync_queue.push_back({"Event Type": "Map Event", "MapID": map_id, "Map Action": map_action})
		return
	
	print([map_id, map_action])
	match map_action['Scope']:
		"Room":
			var room
			for map in GlobalVars.total_maps:
				if map_id == map.get_map_server_id():
					for each_room in map.rooms:
						if each_room.id == map_action['Room ID']:
							room = each_room
			
			match map_action['Action']:
				'Block Exits':
					room.block_exits()
				'Unblock Exits':
					room.unblock_exits()
		
		"Map":
			match map_action['Action']:
				'Victory':
					if GlobalVars.self_netID != 1:
						peer.disconnect_peer(1, true)
					var _result = GlobalVars.get_tree().change_scene('res://Assets/GUI/VictoryScreen/VictoryScreen.tscn')
#
func move_client_to_map(client_obj, map):
	rpc_id(client_obj.get_id()['NetID'], 'prepare_for_map_change', map.get_map_server_id())

remote func prepare_for_map_change(map_id):
	GlobalVars.set_client_state('loading')
	
	var world = get_node("/root/World")
	world.clear_play_map()
	
	rpc_id(1, "send_requested_map_to_requester", GlobalVars.self_obj.get_id()['NetID'], map_id)
#
remote func send_requested_map_to_requester(requester_id, requested_map_id):
	var map
	for mapset in get_node('/root/World').mapsets:
		for flr in mapset.floors.values():
			if requested_map_id == flr.get_map_server_id(): map = flr
	
	var player_id = requester_id
	var map_id = requested_map_id
	var map_data = map.return_map_grid_encoded_to_string()
	var map_rooms = map.return_rooms_encoded_to_dict()
	var map_dict = {"Map ID": map_id, "Grid Data": map_data, "Room Data": map_rooms}
	print(map_data)
	print("Sending map data to requester.")
	rpc_id(player_id, 'receive_requested_map_from_server', map_dict)

# Request map from server.
func request_map_from_server():
	print("Requesting map from server.")
	rpc_id(1, "send_map_to_requester", get_instance_id())
# Send map to requester.
remote func send_map_to_requester(_requester):
	var player_id = get_tree().get_rpc_sender_id()
	var map_id = PlayerInfo.current_map.get_map_server_id()
	var map_data = PlayerInfo.current_map.return_map_grid_encoded_to_string()
	var map_rooms = PlayerInfo.current_map.return_rooms_encoded_to_dict()
	var map_dict = {"Map ID": map_id, "Grid Data": map_data, "Room Data": map_rooms}
	var map_name = GlobalVars.server_map_name
	print(map_data)
	print("Sending map data to requester.")
	rpc_id(player_id, 'receive_map_from_server', map_dict, map_name)
# Receive map from server.
remote func receive_map_from_server(map_dict, map_name):
	GlobalVars.server_map_data = [map_dict['Map ID'], map_dict['Grid Data'], map_dict['Room Data']]
	GlobalVars.server_map_name = map_name
#
remote func receive_requested_map_from_server(map_dict):
	GlobalVars.server_map_data = [map_dict['Map ID'], map_dict['Grid Data'], map_dict['Room Data']]
	unpack_new_map()
#
func unpack_new_map():
	get_node('/root/World').unpack_map(GlobalVars.server_map_data)

func notify_server_map_loaded(map_id):
	rpc_id(1, 'receive_client_has_loaded', GlobalVars.self_obj.get_id()['NetID'], map_id)
	sync_from_sync_queue()
	
remote func receive_client_has_loaded(client_id, map_id):
	var client_obj = get_player_obj_from_netid(client_id)
	client_obj.update_id('Map ID', map_id)
	client_obj.play_anim('idle')
	
	rpc_id(client_id, 'resolve_viewfield')

remote func spawn_object_in_map(object_id):
	var x = object_id['Position'][0]
	var z = object_id['Position'][1]
	
	match object_id['Identifier']:
		'PlagueDoc': 
			var other_player = GlobalVars.obj_spawner.spawn_actor(object_id['Identifier'], GlobalVars.self_obj.get_parent_map(), [x,z], false)
			other_player.set_id(object_id)
			other_player.play_anim('idle')
			self.player_list.append(other_player)

		'Spike Trap':
			var trap = GlobalVars.obj_spawner.spawn_map_object(object_id['Identifier'], GlobalVars.self_obj.get_parent_map(), [x,z], false)
			trap.set_id(object_id)
		
		'Coins':
			var obj = GlobalVars.obj_spawner.spawn_gold(object_id['Gold Value'], get_map_from_map_id(object_id['Map ID']), object_id['Position'], true)
			obj.set_id(object_id)
	
	match object_id['Category']:
		'Inv Item':
			var obj = GlobalVars.obj_spawner.spawn_item(object_id['Identifier'], get_map_from_map_id(object_id['Map ID']), object_id['Position'], true)
			obj.set_id(object_id)
			
	resolve_viewfield()
# ------------------------------------------------------

# SERVER SIDE SIGNAL FUNCS ----------------------
func _player_connected(id):
	print('Player ' + str(id) + ' has connected!')
	
	var spawn_to_map = GlobalVars.self_obj.get_parent_map()
	var spawn_to_pos = GlobalVars.self_obj.get_map_pos().duplicate()
	spawn_to_pos[1] += 1
	
	var new_player = GlobalVars.obj_spawner.spawn_actor('PlagueDoc', spawn_to_map, spawn_to_pos, true)
	new_player.get_parent().remove_child(new_player)
	GlobalVars.self_obj.get_parent().add_child(new_player)
	new_player.update_id('NetID', id)
	player_list.append(new_player)
	new_player.name = 'Player%d' % new_player.get_id()['NetID']
	new_player.play_anim('idle')
	
	rpc_id(id, "receive_id_from_server", id, new_player.get_id()['Instance ID'])

func _player_disconnected(id):
	print('Goodbye player ' + str(id) + '.')
	for player in player_list:
		if player.get_id()['NetID'] == id:
			Server.object_action_event(player.get_id(), {"Command Type": "Remove From Map"})

			player_list.erase(player)
			player.queue_free()

# CLIENT SIDE FUNCS ------------------------------
remote func receive_id_from_server(net_id, instance_id):
	GlobalVars.self_netID = net_id
	GlobalVars.self_instanceID = instance_id

# SERVER UTILITY FUNCTIONS ---
func add_player_to_local_player_list(player):
	player_list.append(player)

func get_map_from_map_id(mapid):
	var map
	for mapset in get_node('/root/World').mapsets:
		if GlobalVars.peer_type == 'client': return mapset
		
		for flr in mapset.floors.values():
			if mapid == flr.get_map_server_id(): map = flr
	return map

func get_player_obj_from_netid(netid):
	for player in player_list:
		if player.get_id()['NetID'] == netid:
			return player

func get_object_from_identity(object_id):
	var map
	for child_map in GlobalVars.total_maps:
		if child_map.get_map_server_id() == object_id['Map ID']: map = child_map

	# determine object
	var object
	var x = object_id['Position'][0]
	var z = object_id['Position'][1]
	var tile_objs = map.get_tile_contents(x, z)

	for obj in tile_objs:
		if obj.get_id()['Instance ID'] == object_id['Instance ID']:
			object = obj
	return object

func get_player_list() -> Array: return player_list

func sync_from_sync_queue():
	GlobalVars.set_client_state('ingame') 
	while sync_queue.size() > 0:
		var event = sync_queue.pop_front()
		
		match event['Event Type']:
			'Action':
				receive_object_action_event(event['ObjectID'], event['Action'])
			'Stat Update':
				receive_actor_stat_update(event['ObjectID'], event['Update'])
			'Notification':
				receive_actor_notif_event(event['ObjectID'], event['Notif Text'], event['Notif Type'])
			'Map Event':
				receive_map_object_event(event['MapID'], event['Map Action'])
			'Action Confirm':
				receive_action_request_confirm(event['Actor Id'], event['Response'])
