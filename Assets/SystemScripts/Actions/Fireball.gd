extends BaseAbility

func _ready():
	spell_name = 'Fireball'
	spell_cost = 25
	spell_length = 3
	spell_power = 20
	visual_effect = preload('res://Assets/Objects/Effects/Fire/Fire.tscn')

func _on_Actions_spell_cast_fireball():
	use()
