extends Node

var parent

func use():
	parent = find_parent('Actions').get_parent()
#	parent.get_inventory_object().equip_item()
	
func _on_Actions_action_equip_item():
	use()
