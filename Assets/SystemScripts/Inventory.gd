extends Node

var inventory_objects = []
var equipped_weapon
var equipped_armour
var equipped_accessory
var gold = 0

func add_to_inventory():
	pass

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

func equip_item():
	pass

func unequip_item():
	pass
	
func drop_item():
	pass

func get_gold_total():
	return gold

func get_inventory_objects():
	return inventory_objects
