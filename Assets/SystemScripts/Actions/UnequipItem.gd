extends Node

var parent

func use():
	parent = find_parent('Actions').get_parent()
	var inventory = parent.get_inventory_object()
	inventory.unequip_item(inventory.get_item_to_act_on().get_inv_item_type())
	
func _on_Actions_action_unequip_item():
	use()
