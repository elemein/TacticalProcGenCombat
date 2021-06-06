extends Node

const INVENTORY_OBJECT = preload("res://Assets/Objects/UIObjects/InventoryUIObject.tscn")

onready var inventory_ui = $InventoryUI
onready var inventory_ui_slots = $InventoryUI/InventoryPanels/InventorySlots
onready var inventory_ui_gold = $InventoryUI/InventoryPanels/Gold/GoldContainer/GoldValue

var inventory_objects = []
var equipped_weapon
var equipped_armour
var equipped_accessory
var gold = 0
var inventory_owner
var owner_type

func setup_inventory(owner):
	inventory_owner = owner
	owner_type = owner.get_obj_type()
	inventory_ui.visible = false

func _physics_process(delta):
	if owner_type == 'Player':
		if Input.is_action_just_pressed("tab"):
			if inventory_ui.visible == false: 
				inventory_ui.visible = true
			else: 
				inventory_ui.visible = false

func add_to_inventory(object):
	inventory_objects.append(object)
	if object.get_inventory_item_type() == 'Weapon':
		equip_item(inventory_objects.size()-1)
	
	var new_object = INVENTORY_OBJECT.instance()
	inventory_ui_slots.add_child(new_object)
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
