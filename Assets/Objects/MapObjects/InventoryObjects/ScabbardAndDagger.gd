extends InvObject

func _init().('Accessory', 'Scabbard and Dagger', 50, true, false):
	pass

var attack_power_bonus = 5

func equip_object():
	item_owner.set_attack_power(item_owner.get_attack_power() + attack_power_bonus)

func unequip_object():
	item_owner.set_attack_power(item_owner.get_attack_power() - attack_power_bonus)
