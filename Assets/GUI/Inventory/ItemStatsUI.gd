# THE CODE IN HERE WILL NOT SCALE WELL TO RESOLUTION, DEF FIX THIS.

extends Control

onready var map = get_node("/root/World/Map")
onready var turn_timer = get_node("/root/World/TurnTimer")

onready var item_stat_row = $InventoryUI/StatHeader


func _physics_process(delta):
	if get_parent().owner_type == 'Player':
		
		if turn_timer.get_turn_in_process() == true: return # lock out while in turn
		
		visible = get_parent().inv_selector.visible
		
		var inventory_objects = get_parent().inventory_objects
		var inv_selector_index = get_parent().inv_selector_index
		if inventory_objects.size() > 0:
			var selected_item = inventory_objects
			for stat_type in selected_item.get_stats():
				var new_object = item_stat_row.instance()
#				inventory_ui_slots.add_child(new_object)
#				ui_objects.append(new_object)
#				new_object.set_object_text(object.get_inv_item_name())
#				new_object.set_object_type(object.get_inv_item_type())
#				new_object.set_equipped(false)
			print(selected_item)
	else:
		visible = false
