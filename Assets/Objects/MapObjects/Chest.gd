extends GameObj

var identity = {"Category": "MapObject", "CategoryType": "Interactable", 
				"Identifier": "BaseChest", 'Map ID': null, 
				'Position': [0,0], 'Instance ID': get_instance_id()}

var relation_rules = {"Blocks Vision": false, "Non-Traversable": false, \
						"Monopolizes Space": true}

func _init().(identity, relation_rules): pass

var contents
