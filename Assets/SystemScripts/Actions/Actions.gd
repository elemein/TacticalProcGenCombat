extends Node

# Attacks
var basic_attack = null
var fireball = null

var self_heal = null
var dash = null

# Inventory Actions
var drop_item = null
var equip_item = null
var unequip_item = null



func _ready():
	# Attacks
	basic_attack = find_node('BasicAttack')
	fireball = find_node('Fireball')

	self_heal = find_node('SelfHeal')
	dash = find_node('Dash')

	# Inventory Actions
	drop_item = find_node('DropItem')
	equip_item = find_node('EquipItem')
	unequip_item = find_node('UnequipItem')


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

