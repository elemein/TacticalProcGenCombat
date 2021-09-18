extends Node

# Attacks
onready var basic_attack = find_node('BasicAttack')
onready var fireball = find_node('Fireball')

onready var self_heal = find_node('SelfHeal')
onready var dash = find_node('Dash')

# Inventory Actions
onready var drop_item = find_node('DropItem')
onready var equip_item = find_node('EquipItem')
onready var unequip_item = find_node('UnequipItem')


# Attacks
func _on_spell_cast_basic_attack():
	basic_attack.use()

	
func _on_spell_cast_fireball():
	fireball.use()


# Inventory Actions
func _on_action_drop_item():
	drop_item.use()


func _on_action_equip_item():
	equip_item.use()

	
func _on_action_unequip_item():
	unequip_item.use()


# Movement
func _on_spell_cast_dash():
	dash.use()


# Buffs
func _on_spell_cast_self_heal():
	self_heal.use()

