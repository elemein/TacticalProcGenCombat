extends BaseAbility

func _ready():
	spell_name = 'Fireball'
	spell_cost = 25
	spell_length = 3
	spell_power = 20
	effect_start_height = 1
	effect_end_height = 1
	visual_effect = preload('res://Assets/Objects/Effects/Fire/Fire.tscn')

func _on_Actions_spell_cast_fireball():
	use()

func _on_Actions_can_cast_fireball():
	if mana_check():
		emit_signal("set_ready_status")
