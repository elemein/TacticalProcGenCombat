extends GameObj
class_name InvObject

var inv_item_type = "" 
var inv_item_name = ""
var item_owner
var value 
var equippable
var usable

func _init(item_type, item_name, item_value, equip, use).("Inv Item"):
	inv_item_type = item_type
	inv_item_name = item_name
	value = item_value
	equippable = equip
	usable = use

func get_gold_value():
	return value

func get_usable(): return false

func get_equippable(): return true

func get_inv_item_type(): return inv_item_type

func get_inv_item_name(): return inv_item_name

func collect_item(tile_objects):
	for object in tile_objects:
		if object.get_obj_type() == 'Player':
			item_owner = object
			object.inventory.add_to_inventory(self)
			map.remove_map_object(self)
