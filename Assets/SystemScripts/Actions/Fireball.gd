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

func use():
	if parent == null: parent = find_parent('Actions').get_parent()
	map = parent.get_parent_map()
	
	# Update mana
	parent.set_mp(parent.get_mp() - spell_cost)

	play_audio()
	
	create_spell_instance()
	set_target_spell_pos()

	set_power()
	do_damage()
