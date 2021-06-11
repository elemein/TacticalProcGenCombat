extends BaseInvObject

func _init().('Weapon', 'Sword', 50, true, false):
	pass

var attack_power_bonus = 10

func equip_object():
	inventory_owner.set_attack_power(inventory_owner.get_attack_power() + attack_power_bonus)

func unequip_object():
	inventory_owner.set_attack_power(inventory_owner.get_attack_power() - attack_power_bonus)
