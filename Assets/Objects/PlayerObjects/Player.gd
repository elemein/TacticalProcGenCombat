extends ActorObj

signal prepare_gui(stats)

var start_stats = {"Max HP" : 100, "HP" : 100, "Max MP": 100, "MP": 100, \
				"HP Regen" : 1, "MP Regen": 6, "Attack Power" : 10, \
				"Crit Chance": 5, "Spell Power" : 20, "Defense" : 0, \
				"Speed": 13, "View Range" : 4}

var minimap_icon = "Player"

var identity = {'Category': 'Actor', 'CategoryType': 'Player', 
				'Identifier': 'PlagueDoc', "Max HP": start_stats['Max HP'],
				'HP': start_stats['Max HP'], 'Max MP': start_stats['Max MP'],
				'MP': start_stats['MP'], 'Facing': null, 'Map ID': null, 
				'Position': [0,0], 'NetID': 1, 'Instance ID': get_instance_id()}

var relation_rules = {"Blocks Vision": false, "Non-Traversable": false, \
						"Monopolizes Space": false}

func _init().(identity, relation_rules, start_stats):
	pass

func _ready():
	var _result = self.connect("prepare_gui", get_node("/root/World/GUI"),"_on_Player_prepare_gui")
	_result = self.connect("status_bar_hp", get_node("/root/World/GUI"), "_on_Player_status_bar_hp")
	_result = self.connect("status_bar_mp", get_node("/root/World/GUI"), "_on_Player_status_bar_mp")	

	emit_signal("prepare_gui", start_stats)
	Signals.emit_signal("player_attack_power_updated", start_stats['Attack Power'])
	Signals.emit_signal("player_spell_power_updated", start_stats['Spell Power'])

	add_sub_nodes_as_children()
	
	GlobalVars.self_instanceObj = self

func add_sub_nodes_as_children():
	add_child(mover)
	mover.set_actor(self)

func set_direction(direction):
	set_actor_dir(direction)
