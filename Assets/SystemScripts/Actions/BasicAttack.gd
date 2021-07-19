extends BaseAbility

func _ready():
	spell_power = 10
	spell_cost = 0
	spell_length = 1
	moving = true
	moving_back = true

func _on_Actions_spell_cast_basic_attack():
	use()
