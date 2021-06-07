extends MeshInstance

const TILE_OFFSET = 2.2

onready var map = get_node("/root/World/Map")

var inventory_item_type = 'Weapon'
var object_type = 'Sword'
var attack_power_bonus = 10
var inventory_owner

var value = 50

var map_pos = []

func get_obj_type(): return object_type

func get_inventory_item_type(): return inventory_item_type

func equip_object():
	inventory_owner.set_attack_power(inventory_owner.get_attack_power() + attack_power_bonus)

func unequip_object():
	inventory_owner.set_attack_power(inventory_owner.get_attack_power() - attack_power_bonus)

func get_map_pos():
	return map_pos

func set_map_pos(new_pos):
	map_pos = new_pos
	translation = Vector3(new_pos[0] * TILE_OFFSET, 0.3, new_pos[1] * TILE_OFFSET)

func get_gold_value():
	return value

func get_usable(): return false

func get_equippable(): return true

func collect_item(tile_objects):
	for object in tile_objects:
		if object.get_obj_type() == 'Player':
			inventory_owner = object
			object.inventory.add_to_inventory(self)
			map.remove_map_object(self)
