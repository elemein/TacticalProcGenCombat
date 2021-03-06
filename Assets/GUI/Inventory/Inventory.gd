# THE CODE IN HERE WILL NOT SCALE WELL TO RESOLUTION, DEF FIX THIS.

extends Node

const INVENTORY_OBJECT = preload("res://Assets/GUI/Inventory/InventoryUIObject.tscn")
const OBJECT_ACTION_MENU = preload("res://Assets/GUI/Inventory/ObjectActionMenu.tscn")

onready var inventory_ui = $InventoryUI
onready var inventory_panels = $InventoryUI/InventoryPanels
onready var inventory_ui_slots = $InventoryUI/InventoryPanels/InventorySlots
onready var inv_title_holder = $InventoryUI/InventoryPanels/Title
onready var inv_gold_holder = $InventoryUI/InventoryPanels/Gold
onready var inventory_ui_gold = $InventoryUI/InventoryPanels/Gold/GoldContainer/GoldValue
onready var inv_selector = $InventorySelector
onready var actmenu_selector = $ActionMenuSelector
onready var item_stats_ui = $ItemStatsUI

# signals
signal display_item_stats

#unsorted vars
var gold = 0
var item_to_act_on

# selector indexes
var actmenu_selector_index = 0
var inv_selector_index = 0
var map

# owner vars
var inventory_owner
var owner_id

# parallel arrays
var inventory_objects = []
var ui_objects = []

# equipped vars
var equipped_weapon
var equipped_armour
var equipped_accessory

# action menu vars
var object_action_menu = OBJECT_ACTION_MENU.instance()
var object_action_menu_open = false
var action_menu_options = []

func setup_inventory(owner):
	inv_selector.visible = false
	actmenu_selector.visible = false
	add_child(object_action_menu)
	object_action_menu.visible = false
	inventory_owner = owner
	owner_id = owner.get_id()
	inventory_ui.visible = false
	map = inventory_owner.get_parent_map()

func _physics_process(_delta):
	if owner_id['CategoryType'] == 'Player':
		var turn_timer = inventory_owner.get_parent_map().get_turn_timer()
		
		if turn_timer.get_turn_in_process() == true: return # lock out while in turn
		
		if is_players_inventory():
			if Input.is_action_just_pressed("tab"):
				Server.request_for_inventory()
			
			if inventory_ui.visible == true:
				if inventory_objects.size() > 0:
					if Input.is_action_just_pressed("w"):
						if !object_action_menu_open: move_inv_selector(-1)
						elif object_action_menu_open: move_actmenu_selector(-1)
					if Input.is_action_just_pressed("s"):
						if !object_action_menu_open: move_inv_selector(1)
						elif object_action_menu_open: move_actmenu_selector(1)
					if Input.is_action_just_pressed("e"):
						if !object_action_menu_open: open_object_action_menu()
						elif object_action_menu_open: handle_action_menu()
					if Input.is_action_just_pressed("q"):
						if !object_action_menu_open: close_inv_ui()
						elif object_action_menu_open: close_object_action_menu()

func is_players_inventory(): return inventory_owner.get_id()['Instance ID'] == GlobalVars.self_instanceID

func handle_action_menu():
	match object_action_menu.get_node("MenuHolder").get_children()[actmenu_selector_index].text:
		'Drop': set_drop_item_action()
		'Equip': set_equip_item_action()
		'Unequip': set_unequip_item_action()

func open_inv_ui():
	inventory_ui.visible = true
	inv_selector_index = 0
	if ui_objects.size() > 0: 
		show_inv_selector()

func close_inv_ui():
	inventory_ui.visible = false
	hide_inv_selector()
	close_object_action_menu()
	inventory_owner.set_inventory_open(false)

func show_inv_selector():
	var dflt_x = inventory_ui.rect_position.x
	var dflt_y = inventory_ui.rect_position.y + inventory_ui_slots.rect_position.y
	
	inv_selector.visible = true
	inv_selector.rect_position = Vector2(dflt_x, dflt_y)
	inv_selector.rect_size = ui_objects[0].rect_size
	emit_signal("display_item_stats")

func hide_inv_selector():
	inv_selector.visible = false

func move_inv_selector(index_mod):
	if object_action_menu_open == false: 
		if index_mod == 1:
			if inv_selector_index != ui_objects.size()-1:
				inv_selector_index += 1
		elif index_mod == -1:
			if inv_selector_index != 0:
				inv_selector_index -= 1
		
		var x = inventory_ui.rect_position.x
		var y = inventory_ui.rect_position.y + inventory_ui_slots.rect_position.y
	
		inv_selector.rect_position = Vector2(x, y + ui_objects[inv_selector_index].rect_position.y)
		emit_signal("display_item_stats")

func show_actmenu_selector():
	move_child(actmenu_selector, get_children().size()-1) # this places selector down the tree of the menu
	var dflt_x = inventory_ui.rect_position.x
	var dflt_y = inventory_ui.rect_position.y + inventory_ui_slots.rect_position.y
	
	actmenu_selector.rect_position = Vector2(dflt_x, dflt_y)
	actmenu_selector.rect_size = action_menu_options[actmenu_selector_index].rect_size
	actmenu_selector.visible = true
	
func hide_actmenu_selector():
	actmenu_selector.visible = false

func move_actmenu_selector(index_mod):
	move_child(actmenu_selector, get_children().size()-1) # this places selector down the tree of the menu
	if object_action_menu_open == true: 
		if index_mod == 1:
			if actmenu_selector_index != action_menu_options.size()-1:
				actmenu_selector_index += 1
		elif index_mod == -1:
			if actmenu_selector_index != 0:
				actmenu_selector_index -= 1
		
		var x = object_action_menu.rect_position.x
		var y = object_action_menu.rect_position.y
	
		actmenu_selector.rect_size = action_menu_options[actmenu_selector_index].rect_size
		actmenu_selector.rect_position = Vector2(x, y + action_menu_options[actmenu_selector_index].rect_position.y)

func open_object_action_menu():
	object_action_menu_open = true
	object_action_menu.visible = true
	
	var x = inventory_ui.rect_position.x + ((ui_objects[inv_selector_index].rect_size.x) * 0.75)
	var y = inv_selector.rect_position.y
	
	object_action_menu.rect_position = Vector2(x, y)
	
	for option in object_action_menu.get_node("MenuHolder").get_children():
		option.queue_free()
		object_action_menu.get_node("MenuHolder").remove_child(option)
		
	
	var optionlist = make_action_option_list()
	for option in optionlist:
		var option_label = Label.new()
		option_label.text = option
		object_action_menu.get_node('MenuHolder').add_child(option_label)
		
	action_menu_options = object_action_menu.get_node("MenuHolder").get_children()
	
	actmenu_selector_index = 0
	show_actmenu_selector()
	actmenu_selector.rect_size = action_menu_options[actmenu_selector_index].rect_size
	actmenu_selector.rect_position = Vector2(x, y + action_menu_options[actmenu_selector_index].rect_position.y)

func close_object_action_menu():
	hide_actmenu_selector()
	object_action_menu.visible = false
	object_action_menu_open = false

func make_action_option_list() -> Array:
	var optionlist = []
	var object = inventory_objects[inv_selector_index]
	
	if object.get_usable(): optionlist.append('Use')
	if object.get_equippable(): 
		
		if object.get_inv_item_type() == 'Weapon':
			if equipped_weapon != object: optionlist.append('Equip')
			if equipped_weapon == object: optionlist.append('Unequip')
		elif object.get_inv_item_type() == 'Accessory':
			if equipped_accessory != object: optionlist.append('Equip')
			if equipped_accessory == object: optionlist.append('Unequip')
		elif object.get_inv_item_type() == 'Armour':
			if equipped_armour != object: optionlist.append('Equip')
			if equipped_armour == object: optionlist.append('Unequip')
		
	
	optionlist.append('Drop')
	
	return optionlist

func build_inv_from_list(inv_list):
	for item in inv_list:
		if GlobalVars.peer_type == 'client':
			var new_item = GlobalVars.obj_spawner.\
			spawn_item(item['Identifier'], 'Inventory', 'Inventory', false)
			new_item.set_id(item)
			inventory_objects.append(new_item)
		
		var new_object = INVENTORY_OBJECT.instance()
		inventory_ui_slots.add_child(new_object)
		ui_objects.append(new_object)
		new_object.set_object_text(item['Identifier'])
		new_object.set_object_type(item['CategoryType'])
#		new_object.set_equipped(false)

func reset_inv_ui():
	for item in inventory_ui_slots.get_children():
		inventory_ui_slots.remove_child(item)
		item.queue_free()

	inventory_objects = []
	ui_objects = []

func add_to_inventory(object):
	inventory_objects.append(object)

func remove_from_inventory(object):
	var idx = -1
	
	for item in inventory_objects:
		idx += 1
		if item == object: break
	
	ui_objects[idx].queue_free()
	inventory_ui_slots.remove_child(ui_objects[idx])
	
	ui_objects.remove(idx)
	inventory_objects.erase(object)

func add_to_gold(currency):
	match typeof(currency):
		TYPE_OBJECT: # If gold is picked up.
			gold += currency.get_gold_value()
		TYPE_INT: # If just adding gold manually.
			gold += currency
	
	inventory_ui_gold.text = str(gold)
	
func subtract_from_gold(currency):
	gold -= currency
	inventory_ui_gold.text = str(gold)

func equip_item():
	var idx = -1
	for object in inventory_objects:
		idx += 1
		if item_to_act_on == object: break
	
	if item_to_act_on.get_inv_item_type() == 'Weapon':
		if equipped_weapon != null:
			unequip_item('Weapon')
		equipped_weapon = item_to_act_on

	elif item_to_act_on.get_inv_item_type() == 'Accessory':
		if equipped_accessory != null:
			unequip_item('Accessory')
		equipped_accessory = item_to_act_on
		
	elif item_to_act_on.get_inv_item_type() == 'Armour':
		if equipped_armour != null:
			unequip_item('Accessory')
		equipped_armour = item_to_act_on

		
		
	ui_objects[idx].set_equipped(true)
	inventory_objects[idx].equip_object()
	close_inv_ui()

func unequip_item(_type):
	var idx = -1
	if item_to_act_on.get_inv_item_type() == 'Weapon':
		for object in inventory_objects:
			idx += 1
			if equipped_weapon == object: break
		equipped_weapon = null

	elif item_to_act_on.get_inv_item_type() == 'Accessory':
		for object in inventory_objects:
			idx += 1
			if equipped_accessory == object: break
		equipped_accessory = null
		
	elif item_to_act_on.get_inv_item_type() == 'Armour':
		for object in inventory_objects:
			idx += 1
			if equipped_armour == object: break
		equipped_armour = null
		
	ui_objects[idx].set_equipped(false)
	inventory_objects[idx].unequip_object()
	
	close_inv_ui()

func set_drop_item_action():
	item_to_act_on = inventory_objects[inv_selector_index]
	inventory_owner.set_action("drop item")

func set_equip_item_action():
	item_to_act_on = inventory_objects[inv_selector_index]
	inventory_owner.set_action("equip item")

func set_unequip_item_action():
	item_to_act_on = inventory_objects[inv_selector_index]
	inventory_owner.set_action("unequip item")

func drop_item():
#	if item_to_act_on in [equipped_weapon, equipped_armour, equipped_accessory]:
#		unequip_item(item_to_act_on.get_inv_item_type())
	
#	item_to_act_on.set_map_pos_and_translation(inventory_owner.get_map_pos())
	map.add_map_object(item_to_act_on)

	remove_from_inventory(item_to_act_on)
	
	close_inv_ui()

func get_gold_total() -> int:
	return gold

func get_inventory_objects() -> Array:
	return inventory_objects

func get_item_to_act_on() -> Object:
	return item_to_act_on

func return_inventory_as_list():
	var to_return = []
	for item in inventory_objects:
		to_return.append(item.get_id())
	return to_return
