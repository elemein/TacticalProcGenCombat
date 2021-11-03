extends GameObj

# vars for minimap
var was_visible = false
var minimap_icon = "Ground"
var identity = {"Category": "MapObject", "CategoryType": "Ground", 
				"Identifier": "BaseGround", 'Map ID': null, 
				'Position': [0,0], 'Instance ID': get_instance_id()}

var relation_rules = {"Blocks Vision": false, "Non-Traversable": false, \
						"Monopolizes Space": false}

func _init().(identity, relation_rules): pass

func _process(_delta):
	if visible:
		was_visible = true
