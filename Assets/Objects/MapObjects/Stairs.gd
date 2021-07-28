extends GameObj

onready var world = get_node('/root/World')

var connects_to

func _init().('Stairs'): pass

func take_stairs(tile_objects):
	for object in tile_objects:
		if object.get_obj_type() == 'Player':
			world.move_to_map(object, parent_mapset.get_mapset_name(), connects_to)
