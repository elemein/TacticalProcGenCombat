extends InvObject

func _init().('Armour', 'Leather Cuirass', 50, true, false):
	pass

var defense_bonus = 10
var attack_power_bonus = 5
var spell_power_bonus = 5

func equip_object():
	item_owner.set_defense(item_owner.get_defense() + defense_bonus)
	item_owner.set_attack_power(item_owner.get_attack_power() + attack_power_bonus)
	item_owner.set_spell_power(item_owner.get_spell_power() + spell_power_bonus)

func unequip_object():
	item_owner.set_defense(item_owner.get_defense() - defense_bonus)
	item_owner.set_attack_power(item_owner.get_attack_power() - attack_power_bonus)
	item_owner.set_spell_power(item_owner.get_spell_power() - spell_power_bonus)
