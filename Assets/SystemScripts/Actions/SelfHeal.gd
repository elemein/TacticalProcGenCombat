extends BaseAbility

func _ready():
	spell_power = 15
	spell_cost = 40
	spell_name = 'SelfHeal'
	spell_description = str("""Self Heal
	Cost: {cost}\tPower: {power}
	
	Heal yourself.
	""").format({'cost': spell_cost, 'power': spell_power})
	effect_start_height = 8
	effect_end_height = 0
	visual_effect = preload("res://Assets/Objects/Effects/Heal/Heal.tscn")

func _on_Actions_spell_cast_self_heal():
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

	heal_user()
	parent.display_notif(("+" + str(spell_final_power)), 'heal')
