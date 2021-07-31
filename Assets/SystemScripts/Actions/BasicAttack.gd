extends BaseAbility

func _ready():
	attack_power = 10
	spell_cost = 0
	spell_length = 1
	moving = true
	moving_back = true
	scales_off_atk_or_spl = 'atk'
	spell_description = str("""Basic Attack
	Cost: {cost}\tPower: {power}
	
	Attack {length} tile in front of you.
	""").format({'cost': spell_cost, 'power': attack_power, 'length': spell_length})

func _on_Actions_spell_cast_basic_attack():
	use()

func _on_Actions_can_cast_basic_attack():
	if mana_check():
		emit_signal("set_ready_status")

func use():
	if parent == null: parent = find_parent('Actions').get_parent()
	map = parent.get_parent_map()
	
	# Update mana
	parent.set_mp(parent.get_mp() - spell_cost)
	
	if moving and not moving_back and not move_check():
		parent = null
		return

	play_audio()

	set_target_actor_pos()

	set_attack_power()

	do_damage()
