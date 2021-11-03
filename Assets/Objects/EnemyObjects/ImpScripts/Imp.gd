extends EnemyObj

const IMP_AI = preload("res://Assets/Objects/EnemyObjects/ImpScripts/ImpAI.gd")

var start_stats = {"Max HP" : 75, "HP" : 80, "Max MP": 40, "MP": 40, \
				"HP Regen" : 1, "MP Regen": 10, "Attack Power" : 5, \
				"Crit Chance": 5, "Spell Power" : 15, "Defense" : 0, \
				 "Speed": GlobalVars.rng.randi_range(5,15), "View Range" : 4}

var minimap_icon = 'Imp'

var identity = {"Category": "Actor", "CategoryType": "Enemy", 
				"Identifier": "Imp", "Max HP": start_stats['Max HP'],
				'HP': start_stats['Max HP'], 'Max MP': start_stats['Max MP'],
				'MP': start_stats['MP'], 'Map ID': null, 'Position': [0,0] , 
				'Facing': 'right', 'Instance ID': get_instance_id()}

var relation_rules = {"Blocks Vision": false, "Non-Traversable": false, \
						"Monopolizes Space": false}

var start_drop_table = {'50': 'Gold', '59': "Sword", '69': 'Magic Staff', '79': \
					'Arcane Necklace', '89': 'Scabbard and Dagger', '94': \
					'Body Armour', '100': 'Leather Cuirass'}

func _init().(IMP_AI, start_drop_table, identity, relation_rules, start_stats):
	pass

func _ready():
	stat_dict['Speed'] = rng.randi_range(5,15)
