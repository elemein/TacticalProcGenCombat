extends InvObject

var identity = {"Category": "Inv Item", "CategoryType": 'Weapon' , 
				"Identifier": 'Sword', "Value": 50, 
				"Equippable": true, "Usable": false, "Consumable": false,
				'Map ID': null, 'Position': [0,0], 'Instance ID': get_instance_id()}

func _init().(identity):
	pass

var attack_power_bonus = 20

func equip_object():
	item_owner.set_attack_power(item_owner.get_attack_power() + attack_power_bonus)

func unequip_object():
	item_owner.set_attack_power(item_owner.get_attack_power() - attack_power_bonus)
	
func get_stats():
	return [[attack_power_bonus, "atk pwr"]]
