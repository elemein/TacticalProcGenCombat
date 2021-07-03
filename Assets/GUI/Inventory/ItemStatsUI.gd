# THE CODE IN HERE WILL NOT SCALE WELL TO RESOLUTION, DEF FIX THIS.

extends Control

onready var map = get_node("/root/World/Map")
onready var turn_timer = get_node("/root/World/TurnTimer")

onready var item_stat_row = $InventoryUI/InventoryPanels/ItemStats
onready var inventory_panels = $InventoryUI/InventoryPanels

var item_stats = []

func _physics_process(delta):
	if get_parent().owner_type == 'Player':
		
		if turn_timer.get_turn_in_process() == true: return # lock out while in turn
		
		visible = get_parent().inv_selector.visible
		
		if visible:
		
			var inventory_objects = get_parent().inventory_objects
			var inv_selector_index = get_parent().inv_selector_index
			if inventory_objects.size() > 0:
				for selected_item in inventory_objects:
					for stat_info in selected_item.get_stats():
						var amount = stat_info[0]
						var stat = stat_info[1]
						
						var new_object = item_stat_row.duplicate()
						new_object.pos_y = 20 * (1 + item_stats.size())
						new_object.set_amount(amount)
						new_object.set_stat(stat)
						
						item_stats.append(new_object)
						inventory_panels.add_child(new_object)
					
	else:
		visible = false
