extends Control

onready var map = get_node("/root/World/Map")
onready var turn_timer = get_node("/root/World/TurnTimer")

onready var item_stat_row = $InventoryUI/InventoryPanels/ItemStats
onready var inventory_panels = $InventoryUI/InventoryPanels

var item_stats = []
var null_items = []

func _physics_process(delta):
	if get_parent().owner_type == 'Player':
		
		if turn_timer.get_turn_in_process() == true: return # lock out while in turn
		
		visible = get_parent().inv_selector.visible
					
	else:
		visible = false
		
func clear_old_stats_window():
	for object in item_stats:
		object.queue_free()
		inventory_panels.remove_child(object)

func show_stat_window():
	if visible:
		item_stats = []
		var inventory_objects = get_parent().inventory_objects
		var inv_selector_index = get_parent().inv_selector_index
		if inventory_objects.size() > 0:
			for stat_info in inventory_objects[inv_selector_index].get_stats():
				var amount = stat_info[0]
				var stat = stat_info[1]
				
				var new_object = item_stat_row.duplicate()
				new_object.pos_y = 20 * item_stats.size()
				new_object.set_amount(amount)
				new_object.set_stat(stat)
				
				item_stats.append(new_object)
				inventory_panels.add_child(new_object)


func _on_Inventory_display_item_stats():
	clear_old_stats_window()
	show_stat_window()
