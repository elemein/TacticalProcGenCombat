extends Node

const INVENTORY_OBJECT = preload("res://Assets/Objects/UIObjects/InventoryUIObject.tscn")
const OBJECT_ACTION_MENU = preload("res://Assets/Objects/UIObjects/ObjectActionMenu.tscn")

onready var inventory_ui = $InventoryUI
onready var inventory_panels = $InventoryUI/InventoryPanels
onready var inventory_ui_slots = $InventoryUI/InventoryPanels/InventorySlots
onready var inv_title_holder = $InventoryUI/InventoryPanels/Title
onready var inv_gold_holder = $InventoryUI/InventoryPanels/Gold
onready var inventory_ui_gold = $InventoryUI/InventoryPanels/Gold/GoldContainer/GoldValue
onready var selector = $Selector

var inventory_objects = []
var ui_objects = []
var equipped_weapon
var equipped_armour
var equipped_accessory
var gold = 0
var inventory_owner
var owner_type
var selector_index = 0
var object_action_menu_open = false

var object_action_menu = OBJECT_ACTION_MENU.instance()

func setup_inventory(owner):
	selector.visible = false
	add_child(object_action_menu)
	object_action_menu.visible = false
	inventory_owner = owner
	owner_type = owner.get_obj_type()
	inventory_ui.visible = false

func _physics_process(delta):
	if owner_type == 'Player':
		if Input.is_action_just_pressed("tab"):
			if inventory_ui.visible == false: open_inv_ui()
			else: close_inv_ui()
		
		if inventory_ui.visible == true:
			if inventory_objects.size() > 0:
				if Input.is_action_just_pressed("w"):
					if selector_index != 0:
						selector_index -= 1
						move_selector()
				if Input.is_action_just_pressed("s"):
					if selector_index != ui_objects.size()-1:
						selector_index += 1
						move_selector()
				if Input.is_action_just_pressed("e"):
					open_object_action_menu()
						

func open_inv_ui():
	inventory_ui.visible = true
	show_selector()
	selector_index = 0

func close_inv_ui():
	inventory_ui.visible = false
	hide_selector()
	object_action_menu.visible = false
	object_action_menu_open = false

func show_selector():
	var dflt_x = inventory_ui.rect_position.x
	var dflt_y = inventory_ui.rect_position.y + inventory_ui_slots.rect_position.y
	
	selector.visible = true
	selector.rect_position = Vector2(dflt_x, dflt_y)
	selector.rect_size = ui_objects[0].rect_size
	
func hide_selector():
	selector.visible = false

func move_selector():
	var dflt_x = inventory_ui.rect_position.x
	var dflt_y = inventory_ui.rect_position.y + inventory_ui_slots.rect_position.y
	
	selector.rect_position = Vector2(dflt_x, dflt_y + ui_objects[selector_index].rect_position.y)


func open_object_action_menu():
	if !object_action_menu_open:
		object_action_menu_open = true
		object_action_menu.visible = true
		var x = inventory_ui.rect_position.x + ((ui_objects[selector_index].rect_size.x) * 0.75)
		var y = selector.rect_position.y
		
		object_action_menu.rect_position = Vector2(x, y)
		
		for option in object_action_menu.get_node("MenuHolder").get_children():
			option.queue_free()
		
		for option in ['Use', 'Equip', 'Unequip', 'Drop']:
			var option_label = Label.new()
			option_label.text = option
			object_action_menu.get_node('MenuHolder').add_child(option_label)

func add_to_inventory(object):
	inventory_objects.append(object)
	if object.get_inventory_item_type() == 'Weapon':
		equip_item(inventory_objects.size()-1)
	
	var new_object = INVENTORY_OBJECT.instance()
	inventory_ui_slots.add_child(new_object)
	ui_objects.append(new_object)
	new_object.set_object_text(object.get_obj_type())
	new_object.set_object_type(object.get_inventory_item_type())
	

func remove_from_inventory():
	pass

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

func equip_item(index):
	if inventory_objects[index].get_inventory_item_type() == 'Weapon':
		if equipped_weapon != null:
			inventory_objects[index].unequip_object()
		
		equipped_weapon = inventory_objects[index]
		inventory_objects[index].equip_object()

func unequip_item(index):
	pass
	
func drop_item():
	pass

func get_gold_total():
	return gold

func get_inventory_objects():
	return inventory_objects
