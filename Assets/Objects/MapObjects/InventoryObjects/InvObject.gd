extends GameObj
class_name InvObject

var inv_item_type = "" 
var inv_item_name = ""
var item_owner
var value 
var equippable
var usable

var minimap_icon = null

func _init(identity).(identity):
	pass

func get_gold_value():
	return value

func get_usable(): return object_identity['Usable']

func get_equippable(): return object_identity['Equippable']

func get_inv_item_type(): return object_identity['CategoryType']

func get_inv_item_name(): return object_identity['Identifier']

func collect_item(tile_objects):
	for object in tile_objects:
		if object.get_id()['CategoryType'] == 'Player':
			item_owner = object
			object.inventory.add_to_inventory(self)
			parent_map.remove_map_object(self)
