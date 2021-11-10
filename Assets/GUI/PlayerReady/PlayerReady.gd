extends VBoxContainer

var example_node = preload("res://Assets/GUI/PlayerReady/PlayerStatus.tscn")

var player_slots = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	yield(Signals, "world_loaded")
#	example_node.visible = false
	setup_player_status_list()
	
func _process(_delta):
	if MultiplayerTestenv.get_client().get_client_state() == 'ingame':
		remove_old_players()
		setup_player_status_list()
	
func setup_player_status_list():
	for player in MultiplayerTestenv.get_client().players_dict.values():

		if MultiplayerTestenv.get_client().get_client_obj().get_parent_map() == player.get_parent_map():

			player = player as ActorObj

			# Add new player to the list
			if not player in player_slots:
				var new_player_node = example_node.instance()
				self.add_child(new_player_node)
				player_slots[player] = {
					'node': new_player_node,
					'name': new_player_node.get_node('Name'),
					'status': new_player_node.get_node('Status')
				}
				new_player_node.visible = true

			# Set the name of the player to the name of the player object
			player_slots[player]['name'].text = player.name

			# Set the ready status
			if not player.ready_status:
				player_slots[player]['status'].text = 'Not Ready'
				player_slots[player]['status'].add_color_override('font_color', Color(1, 0, 0, 1))
			else:
				player_slots[player]['status'].text = 'Ready'
				player_slots[player]['status'].add_color_override('font_color', Color(0, 1, 0, 1))
			
func remove_old_players():
	for player in player_slots:
		if not player in MultiplayerTestenv.get_client().players_dict.values() or \
				not MultiplayerTestenv.get_client().get_client_obj().get_parent_map() == player.get_parent_map():
			remove_child(player_slots[player]['node'])
			player_slots[player]['node'].queue_free()
			player_slots.erase(player)
