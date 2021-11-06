extends AI_Engine

func run_engine():
	reset_vars()
	find_players_in_viewfield()
	determine_ai_state()
	
	if ai_state == 'idle':
		actor.set_action('idle')
	elif ai_state == 'active':
		get_pathfinder_direction_to_player()

		# prioritize healing if able and necessary
		if (actor.get_mp() >= 40) and (actor.get_hp() < 400):
			actor.set_action('self heal')
		
		else:
			if dist_from_player == 1: basic_attack_player()
			elif dist_from_player > 1: move_toward_player()
			else: idle()
