extends GameObj

var value = 10

func _init().('Coins'): pass

func set_gold_value(new_value):
	value = new_value

func get_gold_value():
	return value

func collect_item(tile_objects):
	for object in tile_objects:
		if object.get_obj_type() == 'Player':
			object.inventory.add_to_gold(self)
			map.remove_map_object(self)
