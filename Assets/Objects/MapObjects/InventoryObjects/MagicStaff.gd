extends InvObject

func _init().('Weapon', 'Magic Staff', 50, true, false):
	pass

var spell_power_bonus = 10

func equip_object():
	item_owner.set_spell_power(item_owner.get_spell_power() + spell_power_bonus)

func unequip_object():
	item_owner.set_spell_power(item_owner.get_spell_power() - spell_power_bonus)
	
func get_stats():
	return [[spell_power_bonus, "spl pwr"]]
