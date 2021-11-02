extends ActorObj

var start_stats = {"Max HP" : 100, "HP" : 100, "Max MP": 100, "MP": 100, \
				"HP Regen" : 1, "MP Regen": 6, "Attack Power" : 10, \
				"Crit Chance": 5, "Spell Power" : 20, "Defense" : 0, \
				"Speed": 13, "View Range" : 4}

var minimap_icon = "Player"

var identity = {'Category': 'Actor', 'CategoryType': 'Player', 
				'Identifier': 'PlagueDoc', "Max HP": start_stats['Max HP'],
				'HP': start_stats['Max HP'], 'Max MP': start_stats['Max MP'],
				'MP': start_stats['MP'], 'Facing': null, 'NetID': null, 
				'Map ID': null, 'Position': [0,0], 'Instance ID': get_instance_id()}

func _init().(identity, start_stats):
	pass

func _ready():
	if GlobalVars.peer_type == 'client': set_parent_map(GlobalVars.server_mapset)
	elif GlobalVars.peer_type == 'server': set_parent_map(get_parent())
	
	add_sub_nodes_as_children()

func add_sub_nodes_as_children():
	add_child(mover)
	mover.set_actor(self)

func set_direction(direction):
	set_actor_dir(direction)
