extends MeshInstance

onready var map = get_node("/root/World/Map")

var object_type = 'Sword'

var value = 50

var map_pos = []

func get_obj_type():
	return object_type

func get_map_pos():
	return map_pos

func set_map_pos(new_pos):
	map_pos = new_pos

func get_gold_value():
	return value

func collect_item(tile_objects):
	for object in tile_objects:
		if object.get_obj_type() == 'Player':
			object.inventory.add_to_inventory(self)
			map.remove_map_object(self)
