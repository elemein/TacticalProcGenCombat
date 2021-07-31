extends BaseAbility

func _ready():
	spell_power = 15
	spell_cost = 40
	spell_name = 'SelfHeal'
	spell_description = str("""Self Heal
	Cost: {cost}\tPower: {power}
	
	Heal yourself.
	""").format({'cost': spell_cost, 'power': spell_power})
	spell_heal_user = true
	effect_start_height = 8
	effect_end_height = 0
	visual_effect = preload("res://Assets/Objects/Effects/Heal/Heal.tscn")

func _on_Actions_spell_cast_self_heal():
	use()

func _on_Actions_can_cast_self_heal():
	if mana_check():
		emit_signal("set_ready_status")
