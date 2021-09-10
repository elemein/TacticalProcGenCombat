extends GameObj

var value = 10

var minimap_icon = null

var identity = {"Category": "MapObject", "CategoryType": "Coins", 
				"Identifier": "Coins", 'Map ID': null, 
				'Position': [0,0], 'Instance ID': get_instance_id()}

func _init().(identity): pass

func set_gold_value(new_value):
	value = new_value

func get_gold_value():
	return value

func collect_item(tile_objects):
	for object in tile_objects:
		if object.get_id()['CategoryType'] == 'Player':
			object.inventory.add_to_gold(self)
			parent_map.remove_map_object(self)
