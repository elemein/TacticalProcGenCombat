extends BaseAbility

func _ready():
	spell_name = 'Fireball'
	spell_cost = 25
	spell_length = 3
	spell_power = 20
	effect_start_height = 1
	effect_end_height = 1
	scales_off_atk_or_spl = 'spl'
	spell_description = str("""Fireball
	Cost: {cost}\tPower: {power}
	
	Throw a fireball {length} tiles in front of you.
	""").format({'cost': spell_cost, 'power': spell_power, 'length': spell_length})
	visual_effect = preload('res://Assets/Objects/Effects/Fire/Fire.tscn')

func _on_Actions_spell_cast_fireball():
	use()

func _on_Actions_can_cast_fireball():
	if mana_check():
		emit_signal("set_ready_status")
