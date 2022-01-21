extends Node

var parent

func _ready():
	self.parent  = find_parent('Actions').get_parent()

func drop_item():
	self.parent.get_parent()
	
func equip_item():
	pass
	
func unequip_item():
	pass
