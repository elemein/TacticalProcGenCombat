extends Node

var loading_screen = preload('res://Assets/GUI/LoadingScreen/LoadingScreen.tscn')

# for self_obj
var player_cam = preload('res://Assets/Objects/PlayerObjects/PlayerCam.tscn')
var player_light = preload('res://Assets/Objects/PlayerObjects/PlayerOmniLight.tscn')

var sync_queue = []

var network = NetworkedMultiplayerENet.new()
var network_api = MultiplayerAPI.new()

var map_data
var client_net_id
var client_obj

var players_dict = {}

# Possible states: ['ingame', 'loading', 'character select']
var client_state

func _ready():
	create_client()
	
func _process(delta):
	if get_custom_multiplayer() == null: return
	if not custom_multiplayer.has_network_peer(): return
	custom_multiplayer.poll()

func create_client():
	self.name = 'Client'
#	MultiplayerTestenv.get_client().set_client_state('loading')

	network.create_client('127.0.0.1', 7369)
	network.connect("connection_succeeded", self, "_connected_ok")
	network.connect("connection_failed", self, "_connected_fail")
	
	set_custom_multiplayer(network_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)

func _connected_ok():
	print("Connected to server successfully.")
	rpc_id(1, "send_id_to_requester")

func _connected_fail():
	print("Failed to connect to server.")

remote func receive_id_from_server(id): 
	client_net_id = id
	rpc_id(1, "send_map_to_requester")

remote func receive_map_from_server(map_dict): map_data = map_dict

# Resolve your viewfield and render it to screen.
remote func resolve_viewfield():
	if MultiplayerTestenv.get_client().get_client_state() == 'ingame':
		MultiplayerTestenv.get_client().get_client_obj().find_viewfield()
		MultiplayerTestenv.get_client().get_client_obj().resolve_viewfield_to_screen()
# ------------------------------------------------------

func request_for_player_action(request):
	rpc_id(1, "query_for_action", GlobalVars.get_self_netid(), request)

remote func receive_action_request_confirm(actor_id, response):
	if MultiplayerTestenv.get_client().get_client_state() != 'ingame': # If the client is loading, we don't want to change the map being loaded.
		sync_queue.push_back({"Event Type": "Action Confirm", "Actor Id": actor_id, "Response": response})
		return
	var gui = get_node("/root/World/GUI/Action")
	var player_obj = MultiplayerTestenv.get_client().get_client_obj()
	
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

remote func prepare_for_map_change(map_id):
	MultiplayerTestenv.get_client().set_client_state('loading')
	
	MultiplayerTestenv.get_client().get_client_obj().get_parent_map().clear_play_map()
	
	rpc_id(1, "send_map_to_requester")

# Parse action of object and run required actions to perform action.
remote func receive_object_action_event(object_id, action):
	if MultiplayerTestenv.get_client().get_client_state() != 'ingame': # If the client is loading, we don't want to change the map being loaded.
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
			if GlobalVars.get_self_netid() != 1:
				if object.get_id()['Identifier'] == 'PlagueDoc':
					self.player_list.erase(object)
		'Spawn On Map': # Only for client. Server must spawn objects directly.
			if GlobalVars.peer_type == 'client':
				if object_id['Instance ID'] != GlobalVars.get_self_instance_id():
					spawn_object_in_map(object_id)
			
# -----------------------------------------------------

remote func spawn_object_in_map(object_id):
	var x = object_id['Position'][0]
	var z = object_id['Position'][1]
	
	match object_id['Identifier']:
		'PlagueDoc': 
			var other_player = GlobalVars.obj_spawner.spawn_dumb_actor(object_id['Identifier'], MultiplayerTestenv.get_client().get_client_obj().get_parent_map(), [x,z], false)
			other_player.set_id(object_id)
			other_player.play_anim('idle')
			self.player_list.append(other_player)

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
			
	resolve_viewfield()

func set_client_obj(obj): 
	if obj != null:
		client_obj = obj
		client_obj.update_id('NetID', client_net_id)
		client_obj.connect_to_status_bars()
		client_obj.add_child(player_light.instance())
		client_obj.add_child(player_cam.instance())

func get_client_obj(): return client_obj

func get_client_id(): return client_net_id

func set_client_state(state): 
	client_state = state
	
	if state == 'loading':
		add_child(loading_screen.instance())
	else:
		var to_remove = get_node('/root/MultiplayerTestEnv/Client/LoadingScreen')
		remove_child(to_remove)

func get_client_state(): return client_state

remote func receive_update_all_actor_stats(object_id, new_stat_dict, ready_status):
	if not MultiplayerTestenv.get_client().get_client_state() != 'ingame':
		var object = get_object_from_identity(object_id)
		
		if object == null: return
		
		object.stat_dict = new_stat_dict
		object.ready_status = ready_status


func get_object_from_identity(object_id):
	var map
	for child_map in get_node('/root/World/The Cave').floors.values():
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

func get_map_from_map_id(mapid):
	var map
	for flr in get_node('/root/World/The Cave').floors.values():
		if mapid == flr.get_map_server_id(): map = flr
	return map
