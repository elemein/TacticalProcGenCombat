extends MeshInstance
class_name BaseInvObject

const TILE_OFFSET = 2.2

onready var map = get_node("/root/World/Map")

var inventory_item_type 
var object_type 
var inventory_owner
var map_pos = []
var value 
var equippable
var usable

func _init(item_type, obj_type, item_value, equip, use):
	inventory_item_type = item_type
	object_type = obj_type
	value = item_value
	equippable = equip
	usable = use

func get_gold_value():
	return value

func get_usable(): return false

func get_equippable(): return true

func get_obj_type(): return object_type

func get_inventory_item_type(): return inventory_item_type

func collect_item(tile_objects):
	for object in tile_objects:
		if object.get_obj_type() == 'Player':
			inventory_owner = object
			object.inventory.add_to_inventory(self)
			map.remove_map_object(self)

func get_map_pos():
	return map_pos

func set_map_pos(new_pos):
	map_pos = new_pos
	translation = Vector3(new_pos[0] * TILE_OFFSET, 0.3, new_pos[1] * TILE_OFFSET)

