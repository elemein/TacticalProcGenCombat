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
