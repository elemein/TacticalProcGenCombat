extends AI_Engine

func run_engine():
	reset_vars()
	find_players_in_viewfield()
	
	if player_pos.size() > 0: ai_state = 'active'
	
	if ai_state == 'idle':
		actor.set_action('idle')
	elif ai_state == 'active':
		pathfinder_direction = 'idle'

		pathfind()
		pathfinder_direction = determine_direction_of_path()
		
		if dist_from_player == 1: 
			actor.set_actor_dir(pathfinder_direction)
			match rng.randi_range(1, 2):
				1:	actor.set_action('basic attack')
				2:	actor.set_action('fireball')
		
		elif dist_from_player > 1:
			var move_command = 'move %s' % [pathfinder_direction]
			
			if actor.check_move_action(move_command):
				actor.set_action(move_command)
			else: actor.set_action('idle')
			
		else:
			actor.set_action('idle')
