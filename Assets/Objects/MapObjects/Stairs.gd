extends GameObj

onready var world = get_node('/root/World')

var connects_to

# vars for minimap
var was_visible = false
var minimap_icon = "Stairs"

var identity = {"Category": "MapObject", "CategoryType": "Interactable", 
				"Identifier": "BaseStairs", 'Map ID': null, 
				'Position': [0,0], 'Instance ID': get_instance_id()}

func _init().(identity): pass

func _process(_delta):
	if visible:
		was_visible = true

func interact_w_object(tile_objects):
	for object in tile_objects:
		if object.get_id()['CategoryType'] == 'Player':
			world.move_to_map(object, parent_mapset.get_mapset_name(), connects_to)
