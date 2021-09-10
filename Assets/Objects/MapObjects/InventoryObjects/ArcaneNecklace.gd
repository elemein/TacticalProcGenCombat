extends InvObject

var identity = {"Category": "Inv Item", "CategoryType": 'Accessory' , 
				"Identifier": 'Arcane Necklace', "Value": 50, 
				"Equippable": true, "Usable": false, "Consumable": false,
				'Map ID': null, 'Position': [0,0], 'Instance ID': get_instance_id()}

func _init().(identity):
	pass

var spell_power_bonus = 5

func equip_object():
	item_owner.set_spell_power(item_owner.get_spell_power() + spell_power_bonus)

func unequip_object():
	item_owner.set_spell_power(item_owner.get_spell_power() - spell_power_bonus)
	
func get_stats():
	return [[5, "spl pwr"]]
