extends BaseInvObject

func _init().('Weapon', 'Magic Staff', 50, true, false):
	pass

var spell_power_bonus = 10

func equip_object():
	inventory_owner.set_spell_power(inventory_owner.get_spell_power() + spell_power_bonus)

func unequip_object():
	inventory_owner.set_spell_power(inventory_owner.get_spell_power() - spell_power_bonus)
