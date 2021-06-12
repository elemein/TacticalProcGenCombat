extends Node

# Attacks
signal spell_cast_basic_attack
signal spell_cast_fireball

signal spell_cast_dash

# Inventory Actions
signal action_drop_item
signal action_equip_item
signal action_unequip_item

# Movement
#signal mover_check_move_action(move)
#signal mover_move_actor
#signal mover_set_actor(actor)
#signal mover_set_actor_direction(direction)
#signal mover_set_actor_translation
#signal mover_reset_pos_vars


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

#func _on_mover_check_move_action(move):
#	emit_signal("mover_check_move_action", move)
#
#func _on_mover_move_actor():
#	emit_signal("mover_move_actor")
#
#func _on_mover_set_actor(actor):
#	emit_signal("mover_set_actor", actor)
#
#func _on_mover_set_actor_direction(direction):
#	emit_signal("mover_set_actor_direction", direction)
#
#func _on_mover_set_actor_translation():
#	emit_signal("mover_set_actor_translation")
#
#func _on_mover_reset_pos_vars():
#	emit_signal("mover_reset_pos_vars")



