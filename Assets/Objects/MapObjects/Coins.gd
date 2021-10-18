extends GameObj

var value = 10

var minimap_icon = null

var identity = {"Category": "MapObject", "CategoryType": "Coins", 
				"Identifier": "Coins", 'Map ID': null, 
				'Position': [0,0], 'Instance ID': get_instance_id(),
				'Gold Value': value}

func _init().(identity): pass

func set_gold_value(new_value):
	identity['Gold Value'] = new_value
	value = new_value

func get_gold_value():
	return value

func collect_item(tile_objects):
	for object in tile_objects:
		if object.get_id()['CategoryType'] == 'Player':
			object.gold += value
			Server.object_action_event(object_identity, {"Command Type": "Remove From Map"})
