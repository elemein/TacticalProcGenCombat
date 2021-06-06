extends Node

var inventory_objects = []
var equipped_weapon
var equipped_armour
var equipped_accessory
var gold = 0
var inventory_owner

func add_to_inventory(object):
	inventory_objects.append(object)
	if object.get_inventory_item_type() == 'Weapon':
		equip_item(inventory_objects.size()-1)

func remove_from_inventory():
	pass

func add_to_gold(currency):
	match typeof(currency):
		TYPE_OBJECT: # If gold is picked up.
			gold += currency.get_gold_value()
		TYPE_INT: # If just adding gold manually.
			gold += currency
	
func subtract_from_gold(currency):
	gold -= currency

func equip_item(index):
	if inventory_objects[index].get_inventory_item_type() == 'Weapon':
		if equipped_weapon != null:
			inventory_objects[index].unequip_object()
		
		equipped_weapon = inventory_objects[index]
		inventory_objects[index].equip_object()

func unequip_item(index):
	pass
	
func drop_item():
	pass

func get_gold_total():
	return gold

func get_inventory_objects():
	return inventory_objects
