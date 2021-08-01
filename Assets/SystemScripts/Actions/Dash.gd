extends BaseAbility

func _ready():
	UseSpell = null
	spell_length = 2
	spell_cost = 20
	spell_description = str("""Dash
	Cost: {cost}\t
	
	Dash {length} tiles and move first in a turn.
	""").format({'cost': spell_cost, 'length': spell_length})

func _on_Actions_spell_cast_dash():
	use()

func use():
	map = parent.get_parent_map()
	
	# Update mana
	parent.set_mp(parent.get_mp() - spell_cost)
	
	if move_check() == false:
		parent = null
		return

	play_audio()

	set_target_actor_pos()
	parent.manual_move_char(2)
