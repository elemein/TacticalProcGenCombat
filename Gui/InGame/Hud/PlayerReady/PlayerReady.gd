extends VBoxContainer

onready var example_node = find_node('PlayerStatus')

var player_slots = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	yield(Signals, "world_loaded")
	self.example_node.visible = false
	setup_player_status_list()
	
func _process(_delta):
	if GlobalVars.get_client_state() == 'ingame':
		remove_old_players()
		setup_player_status_list()
	
func setup_player_status_list():
	for player in Server.player_list:

		if GlobalVars.get_self_obj().get_parent_map() == player.get_parent_map():

			player = player as ActorObj

			# Add new player to the list
			if not player in self.player_slots:
				var new_player_node = self.example_node.duplicate()
				self.add_child(new_player_node)
				self.player_slots[player] = {
					'node': new_player_node,
					'name': new_player_node.get_node('Name'),
					'status': new_player_node.get_node('Status')
				}
				new_player_node.visible = true

			# Set the name of the player to the name of the player object
			self.player_slots[player]['name'].text = player.name

			# Set the ready status
			if not player.ready_status:
				self.player_slots[player]['status'].text = 'Not Ready'
				self.player_slots[player]['status'].add_color_override('font_color', Color(1, 0, 0, 1))
			else:
				self.player_slots[player]['status'].text = 'Ready'
				self.player_slots[player]['status'].add_color_override('font_color', Color(0, 1, 0, 1))
			
func remove_old_players():
	for player in self.player_slots:
		if not player in Server.player_list or \
				not GlobalVars.get_self_obj().get_parent_map() == player.get_parent_map():
			remove_child(self.player_slots[player]['node'])
			self.player_slots[player]['node'].queue_free()
			self.player_slots.erase(player)
