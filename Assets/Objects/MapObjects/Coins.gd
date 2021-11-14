extends GameObj

var value = 10

var minimap_icon = null

var identity = {"Category": "MapObject", "CategoryType": "Coins", 
				"Identifier": "Coins", 'Map ID': null, 
				'Position': [0,0], 'Instance ID': get_instance_id(),
				'Gold Value': self.value}

var relation_rules = {"Blocks Vision": false, "Non-Traversable": false, \
						"Monopolizes Space": false}

func _init().(identity, relation_rules): pass

func set_gold_value(new_value):
	self.identity['Gold Value'] = new_value
	self.value = new_value

func get_gold_value():
	return self.value

func collect_item(tile_objects):
	for object in tile_objects:
		if object.get_id()['CategoryType'] == 'Player':
			object.gold += self.value
			Server.object_action_event(object_identity, {"Command Type": "Remove From Map"})
