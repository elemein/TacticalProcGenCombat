extends GameObj

var minimap_icon = "Wall"

var identity = {"Category": "MapObject", "CategoryType": "Wall", 
				"Identifier": "BaseWall", 'Map ID': null, 
				'Position': [0,0], 'Instance ID': get_instance_id()}

var relation_rules = {"Blocks Vision": true, "Non-Traversable": true, \
						"Monopolizes Space": true}

func _init().(identity, relation_rules): pass
