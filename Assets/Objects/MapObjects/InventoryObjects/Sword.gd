extends InvObject

func _init().('Weapon', 'Sword', 50, true, false):
	pass

var attack_power_bonus = 10

func equip_object():
	item_owner.set_attack_power(item_owner.get_attack_power() + attack_power_bonus)

func unequip_object():
	item_owner.set_attack_power(item_owner.get_attack_power() - attack_power_bonus)
