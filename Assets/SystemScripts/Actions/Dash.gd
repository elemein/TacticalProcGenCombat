extends BaseAbility

func _ready():
	UseSpell = null
	spell_length = 2
	spell_cost = 20
	moving = true

func _on_Actions_spell_cast_dash():
	use()

func _on_Actions_can_cast_dash():
	if mana_check():
		emit_signal("set_ready_status")
