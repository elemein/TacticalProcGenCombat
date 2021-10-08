extends InvObject

var identity = {"Category": "Inv Item", "CategoryType": 'Armour' , 
				"Identifier": 'Leather Cuirass', "Value": 50, 
				"Equippable": true, "Usable": false, "Consumable": false,
				'Map ID': null, 'Position': [0,0], 'Instance ID': get_instance_id()}

func _init().(identity):
	pass

var defense_bonus = 10
var attack_power_bonus = 5
var spell_power_bonus = 5

func equip_object():
	item_owner.set_defense(item_owner.get_defense() + defense_bonus)
	item_owner.set_attack_power(item_owner.get_attack_power() + attack_power_bonus)
	item_owner.set_spell_power(item_owner.get_spell_power() + spell_power_bonus)
	item_owner.inventory[self]['equipped'] = true

func unequip_object():
	item_owner.set_defense(item_owner.get_defense() - defense_bonus)
	item_owner.set_attack_power(item_owner.get_attack_power() - attack_power_bonus)
	item_owner.set_spell_power(item_owner.get_spell_power() - spell_power_bonus)
	item_owner.inventory[self]['equipped'] = false
	
func get_stats():
	return [[10, "def"], [5, "atk pwr"], [5, "spl pwr"]]
