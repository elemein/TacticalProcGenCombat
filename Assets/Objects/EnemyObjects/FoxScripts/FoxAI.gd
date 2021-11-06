extends AI_Engine

func run_engine():
	reset_vars()
	find_players_in_viewfield()
	determine_ai_state()
	
	if ai_state == 'idle':
		actor.set_action('idle')
	elif ai_state == 'active':
		get_pathfinder_direction_to_player()
		
		if dist_from_player == 1: basic_attack_player()
		elif dist_from_player > 1: move_toward_player()
		else: idle()
