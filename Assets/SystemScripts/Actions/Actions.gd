extends Node

# Attacks
signal spell_cast_basic_attack
signal spell_cast_fireball

signal spell_cast_self_heal
signal spell_cast_dash

# Inventory Actions
signal action_drop_item
signal action_equip_item
signal action_unequip_item

# Ready status
signal set_ready_status
signal can_cast_fireball
signal can_cast_basic_attack
signal can_cast_dash
signal can_cast_self_heal


# Attacks
func _on_spell_cast_basic_attack():
	emit_signal("spell_cast_basic_attack")
	
func _on_spell_cast_fireball():
	emit_signal("spell_cast_fireball")

# Inventory Actions
func _on_action_drop_item():
	emit_signal("action_drop_item")

func _on_action_equip_item():
	emit_signal("action_equip_item")
	
func _on_action_unequip_item():
	emit_signal("action_unequip_item")

# Movement
func _on_spell_cast_dash():
	emit_signal("spell_cast_dash")

# Buffs
func _on_spell_cast_self_heal():
	emit_signal("spell_cast_self_heal")


func _on_set_ready_status():
	emit_signal("set_ready_status")


func _on_spell_can_cast(action):
	match action:
		'fireball':
			emit_signal("can_cast_fireball")
		'basic attack':
			emit_signal("can_cast_basic_attack")
		'dash':
			emit_signal("can_cast_dash")
		'self heal':
			emit_signal("can_cast_self_heal")
