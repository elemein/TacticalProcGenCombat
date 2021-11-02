extends EnemyObj

const MINOTAUR_AI = preload("res://Assets/Objects/EnemyObjects/MinotaurScripts/MinotaurAI.gd")

var start_stats = {"Max HP" : 500, "HP" : 500, "Max MP": 40, "MP": 40, \
				"HP Regen" : 1, "MP Regen": 2, "Attack Power" : 40, \
				"Crit Chance" : 5, "Spell Power" : 20, "Defense" : 0, \
				 "Speed": 8, "View Range" : 4}

var minimap_icon = 'Minotaur'

var identity = {"Category": "Actor", "CategoryType": "Enemy", 
				"Identifier": "Minotaur", "Max HP": start_stats['Max HP'],
				'HP': start_stats['Max HP'], 'Max MP': start_stats['Max MP'],
				'MP': start_stats['MP'], 'Map ID': null, 'Position': [0,0], 
				'Facing': 'right', 'Instance ID': get_instance_id()}

var start_drop_table = {'50': 'Gold', '59': "Sword", '69': 'Magic Staff', '79': \
					'Arcane Necklace', '89': 'Scabbard and Dagger', '94': \
					'Body Armour', '100': 'Leather Cuirass'}

func _init().(MINOTAUR_AI, start_drop_table, identity, start_stats):
	pass

func _ready():
	stat_dict['Speed'] = rng.randi_range(5,15)
