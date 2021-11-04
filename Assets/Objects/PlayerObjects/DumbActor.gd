extends ActorObj

var start_stats = {"Max HP" : 100, "HP" : 100, "Max MP": 100, "MP": 100, \
				"HP Regen" : 1, "MP Regen": 6, "Attack Power" : 10, \
				"Crit Chance": 5, "Spell Power" : 20, "Defense" : 0, \
				"Speed": 13, "View Range" : 4}

var minimap_icon = "Player"

var identity = {'Category': 'Actor', 'CategoryType': 'Player', 
				'Identifier': 'PlagueDoc', "Max HP": start_stats['Max HP'],
				'HP': start_stats['Max HP'], 'Max MP': start_stats['Max MP'],
				'MP': start_stats['MP'], 'Facing': null, 'Map ID': null, 
				'Position': [0,0], 'NetID': null, 'Instance ID': get_instance_id()}

var relation_rules = {"Blocks Vision": false, "Non-Traversable": false, \
						"Monopolizes Space": false}

func _init().(identity, relation_rules, start_stats):
	pass

#func _ready():
#	add_sub_nodes_as_children()
#
#func add_sub_nodes_as_children():
#	add_child(mover)
#	mover.set_actor(self)
