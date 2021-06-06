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
	gold += currency.get_gold_value()
	
func subtract_from_gold():
	pass

func equip_item():
	pass

func unequip_item():
	pass
	
func drop_item():
	pass
