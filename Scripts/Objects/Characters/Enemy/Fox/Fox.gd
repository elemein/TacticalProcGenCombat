extends EnemyObj

const FOX_AI = preload("res://Scripts/Objects/Characters/Enemy/Fox/FoxAI.gd")

var start_stats = {"Max HP" : 130, "HP" : 130, "Max MP": 0, "MP": 0, \
				"HP Regen" : 1, "MP Regen": 0, "Attack Power" : 10, \
				"Crit Chance": 5, "Spell Power" : 0, "Defense" : 0, \
				 "Speed": GlobalVars.rng.randi_range(5,15), "View Range" : 4}

var minimap_icon = 'Fox'

var identity = {"Category": "Actor", "CategoryType": "Enemy", 
				"Identifier": "Fox", "Max HP": self.start_stats['Max HP'],
				'HP': self.start_stats['Max HP'], 'Max MP': start_stats['Max MP'],
				'MP': self.start_stats['MP'], 'Map ID': null, 'Position': [0,0] ,
				'Facing': 'right', 'Instance ID': get_instance_id()}

var relation_rules = {"Blocks Vision": false, "Non-Traversable": false, \
						"Monopolizes Space": true}

var start_drop_table = {'50': 'Gold', '59': "Sword", '69': 'Magic Staff', '79': \
					'Arcane Necklace', '89': 'Scabbard and Dagger', '94': \
					'Body Armour', '100': 'Leather Cuirass'}

func _init().(FOX_AI, start_drop_table, identity, relation_rules, start_stats):
	pass
