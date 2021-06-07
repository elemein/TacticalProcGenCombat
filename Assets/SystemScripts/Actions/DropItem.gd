extends Node

var parent

func use():
	parent = find_parent('Actions').get_parent()
	parent.get_inventory_object().drop_item()
	
func _on_Actions_action_drop_item():
	use()
