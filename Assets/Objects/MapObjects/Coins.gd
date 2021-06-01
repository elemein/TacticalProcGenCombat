extends MeshInstance

var object_type = 'Coins'

var value = 0

var map_pos = []

func get_obj_type():
	return object_type

func get_map_pos():
	return map_pos

func set_map_pos(new_pos):
	map_pos = new_pos
