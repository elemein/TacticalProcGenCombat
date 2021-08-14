extends GameObj

onready var world = get_node('/root/World')

var connects_to

# vars for minimap
var was_visible = false
var minimap_icon = "Stairs"

func _init().('Stairs'): pass

func _process(_delta):
	if visible:
		was_visible = true

func take_stairs(tile_objects):
	for object in tile_objects:
		if object.get_obj_type() == 'Player':
			world.move_to_map(object, parent_mapset.get_mapset_name(), connects_to)
