extends BaseAbility

func _ready():
	attack_power = 10
	spell_cost = 0
	spell_length = 1
	moving = true
	moving_back = true
	scales_off_atk_or_spl = 'atk'

func _on_Actions_spell_cast_basic_attack():
	use()

func _on_Actions_can_cast_basic_attack():
	if mana_check():
		emit_signal("set_ready_status")
