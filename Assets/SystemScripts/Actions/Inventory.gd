extends Node

var parent

func _ready():
	parent  = find_parent('Actions').get_parent()

func drop_item():
	parent.get_parent()
	
func equip_item():
	pass
	
func unequip_item():
	pass
