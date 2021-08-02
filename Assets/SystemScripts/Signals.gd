extends Node


signal player_attack_power_updated(val)
signal player_spell_power_updated(val)

# Below will never be called but have it here to remove warnings
func _to_string():
	emit_signal("player_attack_power_updated", 0)
	emit_signal("player_spell_power_updated", 0)
