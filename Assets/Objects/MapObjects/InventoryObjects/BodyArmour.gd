extends InvObject

func _init().('Armour', 'Body Armour', 50, true, false):
	pass

var defense_bonus = 30

func equip_object():
	item_owner.set_defense(item_owner.get_defense() + defense_bonus)

func unequip_object():
	item_owner.set_defense(item_owner.get_defense() - defense_bonus)
