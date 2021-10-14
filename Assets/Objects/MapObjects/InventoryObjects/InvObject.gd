extends GameObj
class_name InvObject

var inv_item_type = "" 
var inv_item_name = ""
var item_owner
var value 
var equippable
var usable

var minimap_icon = null
var inventory_icon = preload("res://Assets/Objects/MapObjects/InventoryObjects/placeholder_x76.png")

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
			object.inventory[self] = {'equipped': false, 'description': self.get_id()['Identifier']}
			Server.object_action_event(object_identity, {"Command Type": "Remove From Map"})
