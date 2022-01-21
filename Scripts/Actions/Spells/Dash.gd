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
	
	match move_check():
		2:
			play_audio()

			set_target_actor_pos()
			parent.move_actor_in_facing_dir(2)
			
		1:
			play_audio()

			set_target_actor_pos()
			parent.move_actor_in_facing_dir(1)
			Server.actor_notif_event(parent.get_id(), '!', 'interrupt')
			
		0:
			return

	if GlobalVars.peer_type == 'server':
		Server.update_actor_stat(parent.get_id(), {"Stat": "MP", "Modifier": -spell_cost})
