extends InvObject

var identity = {"Category": "Inv Item", "CategoryType": 'Weapon' , 
				"Identifier": 'Magic Staff', "Value": 50, 
				"Equippable": true, "Usable": false, "Consumable": false}

func _init().(identity):
	pass

var spell_power_bonus = 10

func equip_object():
	item_owner.set_spell_power(item_owner.get_spell_power() + spell_power_bonus)

func unequip_object():
	item_owner.set_spell_power(item_owner.get_spell_power() - spell_power_bonus)
	
func get_stats():
	return [[spell_power_bonus, "spl pwr"]]
